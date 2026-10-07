const assert = require("node:assert/strict");
const test = require("node:test");
const inspect = require("./inspect_build.cjs");

const repository = "codgician/nur-packages";
const job = (name, conclusion = "failure") => ({ name, conclusion });
const packageJob = (name = "example", system = "x86_64-linux", type = "packages") =>
  job(`atelier / Build / ${type}.${system}.${name}`);

function fixture(event = "pull_request") {
  const data = {
    run: {
      id: 123,
      event,
      conclusion: "failure",
      head_branch: event === "push" ? "main" : "bot/example",
      head_sha: "failed-sha",
      head_repository: { full_name: repository },
      pull_requests: event === "push" ? [] : [{ number: 42 }],
      run_attempt: 1,
    },
    pull: {
      number: 42,
      state: "open",
      user: { id: 304539431 },
      labels: [{ name: "bot" }, { name: "bot-deterministic" }],
      head: { ref: "bot/example", sha: "failed-sha", repo: { full_name: repository } },
      base: { ref: "main", sha: "base-sha", repo: { full_name: repository } },
    },
    mainSha: "failed-sha",
    files: [{ filename: "pkgs/example/package.nix" }],
    commits: [],
    jobs: [job("harness", "success"), packageJob()],
    pulls: [],
  };
  const outputs = {};
  const calls = [];
  const methods = Object.fromEntries([
    "pulls.list", "pulls.get", "pulls.listFiles", "pulls.listCommits",
    "actions.listJobsForWorkflowRun", "repos.getBranch",
  ].map((name) => [name, async (args) => {
    calls.push({ name, args });
    if (name === "pulls.get") return { data: data.pull };
    if (name === "repos.getBranch") return { data: { commit: { sha: data.mainSha } } };
    if (name === "pulls.list") return data.pulls;
    if (name === "pulls.listFiles") return data.files;
    if (name === "pulls.listCommits") return data.commits;
    if (name === "actions.listJobsForWorkflowRun") return data.jobs;
    throw new Error(`Unexpected API: ${name}`);
  }]));
  const github = {
    rest: {
      pulls: { list: methods["pulls.list"], get: methods["pulls.get"], listFiles: methods["pulls.listFiles"], listCommits: methods["pulls.listCommits"] },
      actions: { listJobsForWorkflowRun: methods["actions.listJobsForWorkflowRun"] },
      repos: { getBranch: methods["repos.getBranch"] },
    },
    paginate: (method, args) => method(args),
  };
  return {
    data, outputs, calls,
    async execute() {
      await inspect({
        github,
        context: { repo: { owner: "codgician", repo: "nur-packages" }, payload: { workflow_run: data.run } },
        core: { setOutput: (name, value) => { outputs[name] = value; }, notice: () => {} },
      });
      return outputs;
    },
  };
}

const targets = (outputs) => JSON.parse(outputs.targets);
const assertNoRepair = (outputs) => {
  assert.notEqual(outputs.action, "repair");
  assert.equal(Object.hasOwn(outputs, "targets"), false);
};

function buildFix(f) {
  f.data.pull.head.ref = "bot/repair-example";
  f.data.pull.labels = ["bot", "bot-build-fix", "bot-ai-repair"].map((name) => ({ name }));
}
function repairs(f, count) {
  f.data.commits = Array.from({ length: count }, (_, index) => ({ commit: { message: `bot repair(example): attempt ${index + 1}` } }));
}

test("failed main deduplicates packages and emits exact build-fix metadata", async () => {
  const f = fixture("push");
  f.data.jobs.push(packageJob("example", "aarch64-linux", "checks"), packageJob("second"));
  const result = await f.execute();
  assert.equal(result.action, "repair");
  assert.deepEqual(targets(result), [
    {
      package: "example", head_sha: "failed-sha", base_sha: "failed-sha",
      branch: "bot/repair-example", number: "", attempt: 1, kind: "build-fix",
      reason: "atelier / Build / packages.x86_64-linux.example, atelier / Build / checks.aarch64-linux.example",
    },
    {
      package: "second", head_sha: "failed-sha", base_sha: "failed-sha",
      branch: "bot/repair-second", number: "", attempt: 1, kind: "build-fix",
      reason: "atelier / Build / packages.x86_64-linux.second",
    },
  ]);
});

test("main ignores nonpackage, malformed, and nonfailure jobs", async () => {
  const f = fixture("push");
  f.data.jobs = [job("harness", "success"), job("atelier / Eval"), job("other"),
    job("atelier / Build / packages.x86_64.linux.example"), packageJob("Example"),
    packageJob("a".repeat(65)), packageJob("example/other"),
    job("atelier / Build / packages.x86_64-linux.example", "cancelled"),
    job("atelier / Build / checks.x86_64-linux.second", "timed_out"),
    job("atelier / Build / packages.x86_64-linux.third", "success")];
  assertNoRepair(await f.execute());
});

test("main can repair a package while unrelated jobs fail", async () => {
  const f = fixture("push");
  f.data.jobs.push(job("unrelated"), job("atelier / Eval"));
  assert.equal(targets(await f.execute())[0].package, "example");
});

for (const [name, mutate] of [
  ["stale SHA", (f) => { f.data.mainSha = "new-main"; }],
  ["foreign repository", (f) => { f.data.run.head_repository.full_name = "fork/nur-packages"; }],
  ["missing repository", (f) => { delete f.data.run.head_repository; }],
  ["other branch", (f) => { f.data.run.head_branch = "feature"; }],
  ["successful run", (f) => { f.data.run.conclusion = "success"; }],
  ["cancelled run", (f) => { f.data.run.conclusion = "cancelled"; }],
  ["failed harness", (f) => { f.data.jobs[0].conclusion = "failure"; }],
  ["missing harness", (f) => { f.data.jobs.shift(); }],
]) {
  test(`main excludes ${name}`, async () => {
    const f = fixture("push");
    mutate(f);
    assertNoRepair(await f.execute());
  });
}

test("failed main SST build repairs despite Atelier gate failure and skipped NUR", async () => {
  const f = fixture("push");
  f.data.run.id = 37288430302;
  f.data.jobs = [job("harness", "success"), packageJob("sst"), job("atelier / Gate"), job("nur", "skipped")];
  const result = await f.execute();
  assert.equal(result.action, "repair");
  assert.deepEqual(targets(result), [{
    package: "sst", head_sha: "failed-sha", base_sha: "failed-sha",
    branch: "bot/repair-sst", number: "", attempt: 1, kind: "build-fix",
    reason: "atelier / Build / packages.x86_64-linux.sst",
  }]);
});

test("existing same-repository open repair PR skips only its package", async () => {
  const f = fixture("push");
  f.data.jobs.push(packageJob("second"));
  f.data.pulls = [{ state: "open", head: { ref: "bot/repair-example", repo: { full_name: repository } } }];
  assert.deepEqual(targets(await f.execute()).map((target) => target.package), ["second"]);
});

test("main emits no repair when every failing package has an open repair PR", async () => {
  const f = fixture("push");
  f.data.pulls = [{ state: "open", head: { ref: "bot/repair-example", repo: { full_name: repository } } }];
  assertNoRepair(await f.execute());
});

for (const [name, pull] of [
  ["fork", { state: "open", head: { ref: "bot/repair-example", repo: { full_name: "fork/nur-packages" } } }],
  ["closed", { state: "closed", head: { ref: "bot/repair-example", repo: { full_name: repository } } }],
  ["other branch", { state: "open", head: { ref: "bot/example", repo: { full_name: repository } } }],
]) {
  test(`main is not suppressed by ${name} PR`, async () => {
    const f = fixture("push");
    f.data.pulls = [pull];
    assert.equal((await f.execute()).action, "repair");
  });
}

test("existing update PR supplies an update repair target", async () => {
  const f = fixture();
  const result = await f.execute();
  assert.equal(result.action, "repair");
  assert.deepEqual(targets(result), [{
    package: "example", head_sha: "failed-sha", base_sha: "base-sha", branch: "bot/example",
    number: "42", attempt: 1, kind: "update", reason: "atelier / Build / packages.x86_64-linux.example",
  }]);
});

test("new package PR gets its repair kind", async () => {
  const f = fixture();
  f.data.pull.head.ref = "bot/package-issue-12";
  const result = await f.execute();
  assert.equal(targets(result)[0].kind, "new-package");
});

test("subsequent build-fix PR continues at the second repair attempt", async () => {
  const f = fixture();
  buildFix(f);
  repairs(f, 1);
  const result = await f.execute();
  assert.deepEqual(targets(result)[0], {
    package: "example", head_sha: "failed-sha", base_sha: "base-sha", branch: "bot/repair-example",
    number: "42", attempt: 2, kind: "build-fix", reason: "atelier / Build / packages.x86_64-linux.example",
  });
});

test("third repair is allowed but a failed third repair blocks", async () => {
  for (const count of [2, 3]) {
    const f = fixture();
    buildFix(f);
    repairs(f, count);
    f.data.commits.push({ commit: { message: "bot repair(other): unrelated" } });
    const result = await f.execute();
    if (count === 2) {
      assert.equal(targets(result)[0].attempt, 3);
    } else {
      assert.equal(result.action, "block");
      assert.equal(result.reason, "package CI still fails after 3 AI repair attempts");
      assertNoRepair(result);
    }
  }
});

for (const [name, mutate] of [
  ["stale head", (f) => { f.data.pull.head.sha = "new-sha"; }],
  ["human author", (f) => { f.data.pull.user.id = 123; }],
  ["fork head", (f) => { f.data.pull.head.repo.full_name = "fork/nur-packages"; }],
  ["foreign base", (f) => { f.data.pull.base.repo.full_name = "fork/nur-packages"; }],
  ["non-main base", (f) => { f.data.pull.base.ref = "feature"; }],
  ["closed PR", (f) => { f.data.pull.state = "closed"; }],
  ["missing bot label", (f) => { f.data.pull.labels.shift(); }],
  ["unmarked repair branch", (f) => { f.data.pull.head.ref = "bot/repair-example"; }],
  ["repair branch without AI label", (f) => { buildFix(f); f.data.pull.labels.pop(); }],
  ["repair label on update branch", (f) => { f.data.pull.labels.push({ name: "bot-build-fix" }); }],
  ["unmatched branch", (f) => { f.data.pull.head.ref = "bot/other"; }],
  ["outside-package changes", (f) => { f.data.files.push({ filename: "flake.nix" }); }],
  ["cross-package rename", (f) => { f.data.files[0].previous_filename = "pkgs/other/package.nix"; }],
  ["outside-package rename", (f) => { f.data.files[0].previous_filename = "scripts/other.nix"; }],
  ["empty changes", (f) => { f.data.files = []; }],
  ["truncated file list", (f) => { f.data.files = Array.from({ length: 3000 }, () => ({ filename: "pkgs/example/file" })); }],
]) {
  test(`PR excludes ${name}`, async () => {
    const f = fixture();
    mutate(f);
    assertNoRepair(await f.execute());
  });
}

test("PR fallback finds matching open branch when run omits pull numbers", async () => {
  const f = fixture();
  f.data.run.pull_requests = [];
  f.data.pulls = [f.data.pull];
  assert.equal((await f.execute()).action, "repair");
});

test("unassociated PR run is ignored", async () => {
  const f = fixture();
  f.data.run.pull_requests = [];
  assertNoRepair(await f.execute());
});

test("cancelled PR build is ignored before API inspection", async () => {
  const f = fixture();
  f.data.run.conclusion = "cancelled";
  assert.deepEqual(await f.execute(), {});
  assert.deepEqual(f.calls, []);
});

for (const aiRepair of [false, true]) {
  test(`successful PR ${aiRepair ? "requests review" : "merges"} without repair matrix`, async () => {
    const f = fixture();
    f.data.run.conclusion = "success";
    if (aiRepair) buildFix(f);
    const result = await f.execute();
    assert.equal(result.action, aiRepair ? "review" : "merge");
    assert.equal(result.number, "42");
    assertNoRepair(result);
  });
}

test("failed PR harness blocks without targets", async () => {
  const f = fixture();
  f.data.jobs[0].conclusion = "failure";
  const result = await f.execute();
  assert.equal(result.action, "block");
  assert.equal(result.reason, "automation harness failed in build 123");
  assertNoRepair(result);
});

test("nonpackage Atelier failure reruns once then uses existing PR repair route", async () => {
  const f = fixture();
  f.data.jobs[1] = job("atelier / Eval");
  const first = await f.execute();
  assert.equal(first.action, "rerun");
  assertNoRepair(first);
  f.data.run.run_attempt = 2;
  const second = await f.execute();
  assert.equal(targets(second)[0].reason, "atelier / Eval");
});

test("failure outside Atelier blocks the PR", async () => {
  const f = fixture();
  f.data.jobs[1] = job("other");
  const result = await f.execute();
  assert.equal(result.action, "block");
  assert.equal(result.reason, "build 123 failed outside the package build: other");
  assertNoRepair(result);
});
