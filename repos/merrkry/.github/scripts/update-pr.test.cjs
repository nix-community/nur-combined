const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { test } = require('node:test');
const { reportUpdate, readFailedBuilds, finalizePullRequest } = require('./update-pr.cjs');

const context = {
  repo: { owner: 'owner', repo: 'nur' }, serverUrl: 'https://github.com', runId: 1,
  payload: { repository: { default_branch: 'master' } },
};
const derivations = { build: '/nix/store/build.drv', tests: { web: '/nix/store/web.drv' } };

function setup(t, result, pulls = []) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'nur-update-pr-'));
  const previousDirectory = process.cwd();
  const previousEnvironment = { ...process.env };
  process.chdir(directory);
  fs.mkdirSync('.update-results');
  fs.writeFileSync('.update-results/result.json', JSON.stringify({
    success: result.status !== 'failed', results: [result],
  }));
  Object.assign(process.env, {
    PACKAGE: 'example', TARGET_BRANCH: 'master', RUNNER_TEMP: directory,
    ARTIFACT_URL: 'https://github.com/owner/nur/actions/runs/1/artifacts/1',
  });
  t.after(() => {
    process.chdir(previousDirectory);
    process.env = previousEnvironment;
    fs.rmSync(directory, { recursive: true });
  });
  const outputs = {};
  const failures = [];
  const mutations = [];
  const queries = [];
  const github = {
    paginate: async (_, parameters) => { queries.push(parameters); return pulls; },
    rest: { pulls: { list() {}, get: async () => ({ data: pulls[0] }) } },
    graphql: async (query, variables) => {
      const operation = query.match(/(disablePullRequestAutoMerge|convertPullRequestToDraft|markPullRequestReadyForReview|enablePullRequestAutoMerge)\(/)[1];
      mutations.push({ operation, variables });
    },
  };
  const core = {
    setOutput: (name, value) => { outputs[name] = value; },
    setFailed: message => failures.push(message), info() {}, warning() {},
    summary: { addRaw() { return this; }, async write() {} },
  };
  return { github, core, context, outputs, failures, mutations, queries };
}

function result(overrides = {}) {
  return {
    package: 'example', oldVersion: '1.0.0', newVersion: null, status: 'failed',
    changedFiles: ['pkgs/example.nix'], failedStage: 'update',
    steps: { update: { status: 'failed' } }, tests: {}, ...overrides,
  };
}

test('query failure without source changes leaves an existing PR untouched and fails Actions', async t => {
  const state = setup(t, result({ changedFiles: [], error: 'Connection reset' }));
  await reportUpdate(state);
  assert.deepEqual(state.failures, ['Connection reset']);
  assert.equal(state.outputs.publish, undefined);
  assert.deepEqual(state.queries, []);
  assert.deepEqual(state.mutations, []);
});

test('a partial source update is retained as a draft without a build-skip record', async t => {
  const state = setup(t, result());
  await reportUpdate(state);
  assert.equal(state.outputs.publish, 'true');
  assert.equal(state.outputs.draft, 'true');
  assert.equal(state.outputs.branch, 'nur-update/example');
  const body = fs.readFileSync(state.outputs['body-path'], 'utf8');
  assert.match(body, /Failed stage: `update`/);
  assert.doesNotMatch(body, /nur-update-failure:|null|undefined/);
  assert.deepEqual(state.failures, []);
});

test('a failing update disables auto-merge and makes an existing ready PR draft before publishing', async t => {
  const state = setup(t, result(), [{ node_id: 'PR_ID', draft: false, auto_merge: {} }]);
  await reportUpdate(state);
  assert.deepEqual(state.mutations.map(item => item.operation), [
    'disablePullRequestAutoMerge', 'convertPullRequestToDraft',
  ]);
  assert.equal(state.outputs.publish, 'true');
  assert.equal(state.queries[0].head, 'owner:nur-update/example');
});

for (const stage of ['build', 'tests']) {
  test(`${stage} failure records survive a report/discovery round trip on the selected base`, async t => {
    const state = setup(t, result({ failedStage: stage, derivations }));
    process.env.TARGET_BRANCH = 'maintenance';
    await reportUpdate(state);
    const body = fs.readFileSync(state.outputs['body-path'], 'utf8');
    assert.equal(state.outputs.branch, 'nur-update/maintenance/example');
    const pull = {
      draft: true, body, html_url: 'https://github.com/owner/nur/pull/7',
      head: { ref: state.outputs.branch, repo: { full_name: 'owner/nur' } },
    };
    state.github.paginate = async (_, parameters) => {
      assert.equal(parameters.base, 'maintenance');
      return [
        pull,
        {
          ...pull, draft: false, body: body.replace('nur-update:example', 'nur-update:ready'),
          head: { ref: 'nur-update/maintenance/ready', repo: { full_name: 'owner/nur' } },
        },
        { ...pull, html_url: 'WRONG_BRANCH', head: { ref: 'nur-update/example', repo: { full_name: 'owner/nur' } } },
        { ...pull, html_url: 'FOREIGN_REPO', head: { ref: state.outputs.branch, repo: { full_name: 'other/nur' } } },
      ];
    };
    await readFailedBuilds({ ...state, targetBranch: 'maintenance' });
    assert.deepEqual(JSON.parse(state.outputs.builds), {
      example: { derivations, pullRequestUrl: pull.html_url },
    });
  });
}

test('an unchanged update and a known failing derivation leave their existing PRs intact', async t => {
  const state = setup(t, result({ status: 'unchanged', changedFiles: [] }));
  await reportUpdate(state);
  assert.equal(state.outputs.publish, undefined);
  fs.writeFileSync('.update-results/result.json', JSON.stringify({
    success: true, results: [result({ status: 'skipped', failurePullRequest: 'https://github.com/owner/nur/pull/7' })],
  }));
  await reportUpdate(state);
  assert.equal(state.outputs.publish, undefined);
  assert.deepEqual(state.mutations, []);
  assert.deepEqual(state.failures, []);
});

test('a validated update removes failure records, becomes ready, and enables auto-merge for its exact head', async t => {
  const state = setup(t, result({
    status: 'updated', newVersion: '1.1.0', failedStage: undefined,
    steps: { update: { status: 'passed' }, build: { status: 'passed' } },
  }), [{ node_id: 'PR_ID', draft: true, head: { sha: 'HEAD_SHA' }, html_url: 'https://github.com/owner/nur/pull/7' }]);
  await reportUpdate(state);
  assert.equal(state.outputs.draft, 'false');
  assert.equal(state.outputs.built, 'true');
  assert.equal(state.outputs.title, 'example: 1.0.0 -> 1.1.0');
  assert.doesNotMatch(fs.readFileSync(state.outputs['body-path'], 'utf8'), /nur-update-failure:/);
  await finalizePullRequest({ ...state, number: 7, headSha: 'HEAD_SHA', draft: false });
  assert.deepEqual(state.mutations, [
    { operation: 'markPullRequestReadyForReview', variables: { id: 'PR_ID' } },
    { operation: 'enablePullRequestAutoMerge', variables: { id: 'PR_ID', head: 'HEAD_SHA' } },
  ]);
});

test('a partial update stays draft without enabling auto-merge', async t => {
  const state = setup(t, result(), [{
    node_id: 'PR_ID', draft: true, head: { sha: 'HEAD_SHA' }, html_url: 'https://github.com/owner/nur/pull/7',
  }]);
  await finalizePullRequest({ ...state, number: 7, headSha: 'HEAD_SHA', draft: true });
  assert.deepEqual(state.mutations, []);
});

test('a changed PR head prevents readiness and auto-merge mutations', async t => {
  const state = setup(t, result(), [{ head: { sha: 'OTHER_SHA' } }]);
  await assert.rejects(
    finalizePullRequest({ ...state, number: 7, headSha: 'HEAD_SHA', draft: false }),
    /head changed/,
  );
  assert.deepEqual(state.mutations, []);
});

test('retrying a finalized PR leaves an enabled or completed merge intact', async t => {
  const state = setup(t, result());
  for (const pull of [
    { merged: true, html_url: 'https://github.com/owner/nur/pull/7' },
    { draft: false, auto_merge: {}, head: { sha: 'HEAD_SHA' }, html_url: 'https://github.com/owner/nur/pull/7' },
  ]) {
    state.github.rest.pulls.get = async () => ({ data: pull });
    await finalizePullRequest({ ...state, number: 7, headSha: 'HEAD_SHA', draft: false });
  }
  assert.deepEqual(state.mutations, []);
});
