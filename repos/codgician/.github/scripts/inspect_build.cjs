module.exports = async ({ github, context, core }) => {
  const run = context.payload.workflow_run;
  const repository = `${context.repo.owner}/${context.repo.repo}`;
  const targets = [];
  if (run.conclusion !== "success" && run.conclusion !== "failure") return;
  const listJobs = () => github.paginate(github.rest.actions.listJobsForWorkflowRun, {
    owner: context.repo.owner,
    repo: context.repo.repo,
    run_id: run.id,
    filter: "latest",
    per_page: 100,
  });
  const emitRepair = () => {
    if (targets.length === 0) return;
    core.setOutput("action", "repair");
    core.setOutput("targets", JSON.stringify(targets));
  };

  if (run.event === "push") {
    if (
      run.conclusion !== "failure" ||
      run.head_branch !== "main" ||
      run.head_repository?.full_name !== repository
    ) return;
    const { data: main } = await github.rest.repos.getBranch({
      owner: context.repo.owner,
      repo: context.repo.repo,
      branch: "main",
    });
    if (main.commit.sha !== run.head_sha) {
      core.notice(`Main advanced after build ${run.id}; ignoring stale result`);
      return;
    }
    const jobs = await listJobs();
    if (!jobs.some((job) => job.name === "harness" && job.conclusion === "success")) return;
    const failures = new Map();
    for (const job of jobs) {
      if (job.conclusion !== "failure") continue;
      const match = /^atelier \/ Build \/ (packages|checks)\.[^.]+\.([a-z][a-z0-9_-]{0,63})$/.exec(job.name);
      if (!match) continue;
      const packageName = match[2];
      if (!failures.has(packageName)) failures.set(packageName, []);
      failures.get(packageName).push(job.name);
    }
    for (const [packageName, names] of failures) {
      const branch = `bot/repair-${packageName}`;
      const pulls = await github.paginate(github.rest.pulls.list, {
        owner: context.repo.owner,
        repo: context.repo.repo,
        state: "open",
        head: `${context.repo.owner}:${branch}`,
        per_page: 100,
      });
      if (pulls.some((pull) => pull.state === "open" && pull.head.ref === branch && pull.head.repo?.full_name === repository)) continue;
      targets.push({
        package: packageName,
        head_sha: run.head_sha,
        base_sha: run.head_sha,
        branch,
        number: "",
        attempt: 1,
        kind: "build-fix",
        reason: names.join(", "),
      });
    }
    emitRepair();
    return;
  }
  if (run.event !== "pull_request") return;

  let pullNumber = run.pull_requests?.[0]?.number;
  if (!pullNumber) {
    const pulls = await github.paginate(github.rest.pulls.list, {
      owner: context.repo.owner,
      repo: context.repo.repo,
      state: "open",
      head: `${context.repo.owner}:${run.head_branch}`,
      per_page: 100,
    });
    pullNumber = pulls.find((pull) => pull.head.sha === run.head_sha)?.number;
  }
  if (!pullNumber) {
    core.notice("Completed build is not associated with an open pull request");
    return;
  }
  const { data: pull } = await github.rest.pulls.get({
    owner: context.repo.owner,
    repo: context.repo.repo,
    pull_number: pullNumber,
  });
  const labels = new Set(pull.labels.map((label) => label.name));
  if (
    pull.state !== "open" ||
    pull.base.ref !== "main" ||
    pull.base.repo?.full_name !== repository ||
    pull.user?.id !== 304539431 ||
    pull.head.repo?.full_name !== repository ||
    !labels.has("bot") ||
    (!labels.has("bot-deterministic") && !labels.has("bot-ai-repair"))
  ) {
    core.notice(`PR #${pullNumber} is not an owned package automation pull request`);
    return;
  }
  if (pull.head.sha !== run.head_sha) {
    core.notice(`PR #${pullNumber} advanced after build ${run.id}; ignoring stale result`);
    return;
  }
  const files = await github.paginate(github.rest.pulls.listFiles, {
    owner: context.repo.owner,
    repo: context.repo.repo,
    pull_number: pullNumber,
    per_page: 100,
  });
  const packages = new Set();
  let packageOnly = files.length > 0 && files.length < 3000;
  for (const file of files) {
    for (const path of [file.filename, file.previous_filename].filter(Boolean)) {
      const match = /^pkgs\/([a-z][a-z0-9_-]{0,63})\/.+/.exec(path);
      if (!match) {
        packageOnly = false;
        break;
      }
      packages.add(match[1]);
    }
    if (!packageOnly) break;
  }
  packageOnly &&= packages.size === 1;
  if (!packageOnly) {
    core.notice(`PR #${pullNumber} is not confined to one package`);
    return;
  }
  const packageName = [...packages][0];
  const newPackage = /^bot\/package-issue-[1-9][0-9]*$/.test(pull.head.ref);
  const buildFix = labels.has("bot-build-fix");
  if (
    (buildFix && (pull.head.ref !== `bot/repair-${packageName}` || !labels.has("bot-ai-repair"))) ||
    (!buildFix && pull.head.ref !== `bot/${packageName}` && !newPackage)
  ) {
    core.notice(`PR #${pullNumber} branch does not match package ${packageName}`);
    return;
  }
  const kind = buildFix ? "build-fix" : newPackage ? "new-package" : "update";
  const commits = await github.paginate(github.rest.pulls.listCommits, {
    owner: context.repo.owner,
    repo: context.repo.repo,
    pull_number: pullNumber,
    per_page: 100,
  });
  const repairPrefix = `bot repair(${packageName}):`;
  const attempts = commits.filter((commit) => commit.commit.message.startsWith(repairPrefix)).length;
  const nextAttempt = attempts + 1;
  core.setOutput("number", String(pullNumber));
  core.setOutput("head_sha", pull.head.sha);

  if (run.conclusion === "success") {
    core.setOutput("action", labels.has("bot-ai-repair") ? "review" : "merge");
    return;
  }
  const jobs = await listJobs();
  const successful = new Set(["success", "neutral", "skipped"]);
  const failedJobs = jobs.filter((job) => !successful.has(job.conclusion));
  const harness = jobs.find((job) => job.name === "harness");
  const escapedPackage = packageName.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const packageBuild = new RegExp(`^atelier / Build / (?:packages|checks)\\.[^.]+\\.${escapedPackage}$`);
  const packageFailures = failedJobs.filter((job) => packageBuild.test(job.name));
  const atelierFailures = failedJobs.filter((job) => job.name.startsWith("atelier / "));
  const onlyAtelierFailed = atelierFailures.length > 0 && atelierFailures.length === failedJobs.length;
  const repair = (failures) => {
    const reason = failures.map((job) => job.name).join(", ");
    core.setOutput("reason", reason);
    targets.push({
      package: packageName,
      head_sha: pull.head.sha,
      base_sha: pull.base.sha,
      branch: pull.head.ref,
      number: String(pullNumber),
      attempt: nextAttempt,
      kind,
      reason,
    });
    emitRepair();
  };
  if (harness?.conclusion !== "success") {
    core.setOutput("action", "block");
    core.setOutput("reason", `automation harness failed in build ${run.id}`);
    return;
  }
  if (packageFailures.length > 0) {
    if (attempts >= 3) {
      core.setOutput("action", "block");
      core.setOutput("reason", `package CI still fails after ${attempts} AI repair attempts`);
    } else {
      repair(packageFailures);
    }
    return;
  }
  if (onlyAtelierFailed && Number(run.run_attempt || 1) < 2) {
    core.setOutput("action", "rerun");
    core.setOutput("reason", `retrying non-package Atelier failure: ${atelierFailures.map((job) => job.name).join(", ")}`);
    return;
  }
  if (onlyAtelierFailed && attempts < 3) {
    repair(atelierFailures);
    return;
  }
  core.setOutput("action", "block");
  core.setOutput("reason", `build ${run.id} failed outside the package build: ${failedJobs.map((job) => job.name).join(", ")}`);
};
