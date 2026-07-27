#!/usr/bin/env -S deno run --allow-read --allow-write --allow-run --allow-env

/**
 * Updates a single Nix package and outputs version info for GitHub Actions.
 *
 * Usage: deno run --allow-all scripts/update-package/main.ts <package-name>
 *
 * Update method:
 *   - If packages/<name>/update.sh exists, run it
 *   - Otherwise, run nix-update
 *
 * Exit codes:
 *   0 - Success (update applied or already up-to-date)
 *   1 - Error (update or build failed)
 */

async function run(
  cmd: string[],
): Promise<{ success: boolean; output: string }> {
  const command = new Deno.Command(cmd[0], {
    args: cmd.slice(1),
    stdout: "piped",
    stderr: "piped",
  });

  const { code, stdout, stderr } = await command.output();
  const output =
    new TextDecoder().decode(stdout) + new TextDecoder().decode(stderr);

  return { success: code === 0, output };
}

async function runPassthrough(cmd: string[]): Promise<boolean> {
  const command = new Deno.Command(cmd[0], {
    args: cmd.slice(1),
    stdout: "inherit",
    stderr: "inherit",
  });

  const { code } = await command.output();
  return code === 0;
}

async function getVersion(attr: string): Promise<string> {
  const { success, output } = await run([
    "nix",
    "eval",
    `.#${attr}.version`,
    "--raw",
  ]);
  return success ? output.trim() : "unknown";
}

function output(key: string, value: string): void {
  console.log(`${key}=${value}`);

  const githubOutput = Deno.env.get("GITHUB_OUTPUT");
  if (githubOutput) {
    Deno.writeTextFileSync(githubOutput, `${key}=${value}\n`, { append: true });
  }
}

async function fileExists(path: string): Promise<boolean> {
  try {
    const stat = await Deno.stat(path);
    return stat.isFile;
  } catch {
    return false;
  }
}

async function main(): Promise<void> {
  const packageName = Deno.args[0];
  if (!packageName) {
    console.error("Usage: main.ts <package-name>");
    Deno.exit(1);
  }

  const scriptDir = new URL(".", import.meta.url).pathname;
  const repoRoot = scriptDir.replace(/\/scripts\/update-package\/$/, "");
  Deno.chdir(repoRoot);

  Deno.env.set("NIX_PATH", "nixpkgs=flake:nixpkgs");

  const updateScript = `./packages/${packageName}/update.sh`;
  const hasCustomUpdate = await fileExists(updateScript);

  console.log(`=== Updating ${packageName} ===`);
  console.log(`method: ${hasCustomUpdate ? "custom" : "nix-update"}`);

  const oldVersion = await getVersion(packageName);
  console.log(`Current version: ${oldVersion}`);

  // Get current HEAD before update
  const { output: headBefore } = await run(["git", "rev-parse", "HEAD"]);
  const oldHead = headBefore.trim();

  // Run update
  const updateSuccess = hasCustomUpdate
    ? await runPassthrough([updateScript])
    : await runPassthrough(["nix-update", packageName, "--flake", "--commit"]);

  if (!updateSuccess) {
    console.error(`ERROR: Update failed for ${packageName}`);
    Deno.exit(1);
  }

  // Stage changes so nix flake can see updated files
  await run(["git", "add", "-A"]);

  // Get HEAD after update
  const { output: headAfter } = await run(["git", "rev-parse", "HEAD"]);
  const newHead = headAfter.trim();

  const newVersion = await getVersion(packageName);
  console.log(`New version: ${newVersion}`);

  // Check if update created a new commit
  if (oldHead !== newHead) {
    output("updated", "true");
    output("old_version", oldVersion);
    output("new_version", newVersion);

    // Build and verify
    console.log(`Building ${packageName}...`);
    if (
      !(await runPassthrough([
        "nix",
        "build",
        `.#${packageName}`,
        "--print-build-logs",
      ]))
    ) {
      console.error(`ERROR: Build failed for ${packageName}`);
      Deno.exit(1);
    }

    // Run per-package check script if exists
    const checkScript = `./packages/${packageName}/check.sh`;
    if (await fileExists(checkScript)) {
      console.log(`Running check script for ${packageName}...`);
      if (!(await runPassthrough([checkScript]))) {
        console.error(`ERROR: Check failed for ${packageName}`);
        Deno.exit(1);
      }
    }

    console.log(
      `SUCCESS: ${packageName} updated from ${oldVersion} to ${newVersion}`,
    );
  } else {
    output("updated", "false");
    console.log(`INFO: ${packageName} is already up-to-date`);
  }
}

main();
