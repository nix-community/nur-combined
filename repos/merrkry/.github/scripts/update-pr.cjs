const fs = require('node:fs');
const path = require('node:path');

function updateBranch(packageName, targetBranch, defaultBranch) {
  if (targetBranch === defaultBranch) return `nur-update/${packageName}`;
  return `nur-update/${targetBranch}/${packageName}`;
}

async function makeDraft(github, pull) {
  if (pull.auto_merge) {
    await github.graphql(`mutation($id: ID!) {
      disablePullRequestAutoMerge(input: {pullRequestId: $id}) { clientMutationId }
    }`, { id: pull.node_id });
  }
  if (!pull.draft) {
    await github.graphql(`mutation($id: ID!) {
      convertPullRequestToDraft(input: {pullRequestId: $id}) { clientMutationId }
    }`, { id: pull.node_id });
  }
}

exports.readFailedBuilds = async ({ github, context, core, targetBranch }) => {
  const pulls = await github.paginate(github.rest.pulls.list, {
    ...context.repo, state: 'open', base: targetBranch, per_page: 100,
  });
  const builds = {};
  for (const pull of pulls) {
    if (!pull.draft) continue;
    const marker = pull.body?.match(/<!-- nur-update:([^\s<>]+) -->/);
    const record = pull.body?.match(/<!-- nur-update-failure:(.+?) -->/);
    if (!marker || !record) continue;
    const branch = updateBranch(marker[1], targetBranch, context.payload.repository.default_branch);
    if (pull.head.repo?.full_name !== `${context.repo.owner}/${context.repo.repo}` || pull.head.ref !== branch) continue;
    builds[marker[1]] = {
      derivations: JSON.parse(record[1]),
      pullRequestUrl: pull.html_url,
    };
  }
  core.setOutput('builds', JSON.stringify(builds));
};

exports.reportUpdate = async ({ github, context, core }) => {
  const report = JSON.parse(fs.readFileSync('.update-results/result.json', 'utf8'));
  const result = report.results[0];
  if (report.error || report.results.length !== 1 || result.package !== process.env.PACKAGE) {
    core.setFailed(report.error || 'Expected one result for the selected package');
    return;
  }

  core.setOutput('built', result.steps.build?.status === 'passed' ? 'true' : 'false');
  if (result.status === 'skipped') {
    core.info(`${result.package}: ${result.reason} (${result.failurePullRequest})`);
    return;
  }
  if (result.changedFiles.length === 0) {
    if (!report.success) core.setFailed(result.error || `Package update failed at ${result.failedStage}`);
    return;
  }

  const draft = result.status !== 'updated';
  const branch = updateBranch(result.package, process.env.TARGET_BRANCH, context.payload.repository.default_branch);
  if (draft) {
    // Disable merging before create-pull-request pushes an incomplete update.
    const pulls = await github.paginate(github.rest.pulls.list, {
      ...context.repo, state: 'open', base: process.env.TARGET_BRANCH,
      head: `${context.repo.owner}:${branch}`, per_page: 100,
    });
    for (const pull of pulls) await makeDraft(github, pull);
  }

  const title = result.newVersion
    ? `${result.package}: ${result.oldVersion} -> ${result.newVersion}`
    : `${result.package}: update`;
  const runUrl = `${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}`;
  const tests = Object.entries(result.tests)
    .map(([name, test]) => `- Test \`${name}\`: ${test.status}`);
  const upstream = [];
  if (result.changelog) upstream.push(`[Upstream release / changelog](${result.changelog})`);
  if (result.compare) upstream.push(`[Upstream changes](${result.compare})`);
  const markers = [`<!-- nur-update:${result.package} -->`];
  if (['build', 'tests'].includes(result.failedStage)) {
    markers.push(`<!-- nur-update-failure:${JSON.stringify(result.derivations)} -->`);
  }
  const body = [
    ...markers,
    '',
    result.newVersion
      ? `Update \`${result.package}\`: \`${result.oldVersion}\` -> \`${result.newVersion}\`.`
      : `Update \`${result.package}\` from \`${result.oldVersion || 'unknown'}\`.`,
    '',
    ...upstream,
    ...(upstream.length ? [''] : []),
    ...(result.failedStage ? [`- Failed stage: \`${result.failedStage}\``] : []),
    ...(result.error ? [`- Error: ${result.error}`] : []),
    `- Update: ${result.steps.update?.status || 'not run'}`,
    `- Build: ${result.steps.build?.status || 'not run'}`,
    ...tests,
    '',
    `[Workflow run](${runUrl})`,
    ...(process.env.ARTIFACT_URL ? [`[Logs, result and source diff](${process.env.ARTIFACT_URL})`] : []),
  ].join('\n');
  const bodyPath = path.join(process.env.RUNNER_TEMP, 'nur-pr-body.md');
  fs.writeFileSync(bodyPath, body);
  core.setOutput('branch', branch);
  core.setOutput('body-path', bodyPath);
  core.setOutput('publish', 'true');
  core.setOutput('draft', draft ? 'true' : 'false');
  core.setOutput('title', title);
};

exports.finalizePullRequest = async ({ github, context, core, number, headSha, draft }) => {
  const { data: pull } = await github.rest.pulls.get({ ...context.repo, pull_number: number });
  if (pull.merged) {
    core.info(`Package update already merged: ${pull.html_url}`);
    return;
  }
  if (pull.head.sha !== headSha) {
    throw new Error('Pull request head changed after publishing the update');
  }
  if (draft) {
    await makeDraft(github, pull);
    core.warning(`Incomplete package update saved in ${pull.html_url}`);
  } else {
    if (pull.draft) {
      await github.graphql(`mutation($id: ID!) {
        markPullRequestReadyForReview(input: {pullRequestId: $id}) { clientMutationId }
      }`, { id: pull.node_id });
    }
    if (!pull.auto_merge) {
      await github.graphql(`mutation($id: ID!, $head: GitObjectID!) {
        enablePullRequestAutoMerge(input: {
          pullRequestId: $id, mergeMethod: SQUASH, expectedHeadOid: $head
        }) { clientMutationId }
      }`, { id: pull.node_id, head: headSha });
    }
  }
  await core.summary.addRaw(`[${draft ? 'Draft update' : 'Validated update'}](${pull.html_url}).\n`).write();
};
