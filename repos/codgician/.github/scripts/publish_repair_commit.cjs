// Publishes the staged package repair as one signed commit whose parent is the
// exact failed pull request head, so commits already on the branch (such as the
// version bump being repaired) are preserved.
const { execFileSync } = require("node:child_process");
const { readFileSync } = require("node:fs");

const git = (...args) => execFileSync("git", args, { encoding: "utf8", maxBuffer: 256 * 1024 * 1024 });

module.exports = async ({ github, context, core }) => {
  const { BRANCH: branch, EXPECTED_HEAD: expectedHead, PR_NUMBER: prNumber, COMMIT_MESSAGE: message, TITLE: title, BODY_PATH: bodyPath } =
    process.env;
  const repo = { owner: context.repo.owner, repo: context.repo.repo };
  const pullNumber = Number(prNumber);
  if (!Number.isSafeInteger(pullNumber) || pullNumber < 1) throw new Error(`Invalid pull request number ${prNumber}`);
  if (git("rev-parse", "HEAD").trim() !== expectedHead) throw new Error(`Checkout is not the expected head ${expectedHead}`);

  const tree = [];
  const fields = git("diff", "--cached", "--name-status", "--no-renames", "-z", expectedHead).split("\0");
  for (let index = 0; index + 1 < fields.length; index += 2) {
    const [status, path] = [fields[index], fields[index + 1]];
    if (status === "D") {
      tree.push({ path, mode: "100644", type: "blob", sha: null });
      continue;
    }
    const [mode] = git("ls-files", "--stage", "-z", "--", path).split(" ");
    if (mode !== "100644" && mode !== "100755") throw new Error(`Unsupported file mode ${mode} for ${path}`);
    const content = Buffer.from(execFileSync("git", ["cat-file", "blob", `:${path}`], { maxBuffer: 256 * 1024 * 1024 })).toString("base64");
    const { data: blob } = await github.rest.git.createBlob({ ...repo, content, encoding: "base64" });
    tree.push({ path, mode, type: "blob", sha: blob.sha });
  }
  if (tree.length === 0) throw new Error("Repair patch has no staged changes");

  const { data: headCommit } = await github.rest.git.getCommit({ ...repo, commit_sha: expectedHead });
  const { data: newTree } = await github.rest.git.createTree({ ...repo, base_tree: headCommit.tree.sha, tree });
  const expectedTree = git("write-tree").trim();
  if (newTree.sha !== expectedTree) {
    throw new Error(`Published tree ${newTree.sha} differs from validated candidate tree ${expectedTree}`);
  }
  // Omitting author and committer lets GitHub sign the commit as the app.
  const { data: commit } = await github.rest.git.createCommit({ ...repo, message, tree: newTree.sha, parents: [expectedHead] });
  if (!commit.verification?.verified) throw new Error(`Repair commit ${commit.sha} is not verified: ${commit.verification?.reason}`);
  // The new commit's only parent is expectedHead, so a non-forced update succeeds
  // only while the branch still points at expectedHead.
  await github.rest.git.updateRef({ ...repo, ref: `heads/${branch}`, sha: commit.sha, force: false });
  await github.rest.pulls.update({ ...repo, pull_number: pullNumber, title, body: readFileSync(bodyPath, "utf8") });
  core.info(`Published repair commit ${commit.sha} on ${branch} (parent ${expectedHead})`);
  core.setOutput("pull-request-number", String(pullNumber));
  core.setOutput("pull-request-head-sha", commit.sha);
};
