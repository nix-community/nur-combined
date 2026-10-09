import { defineSource } from "nix-repin";
import { Octokit } from "octokit";
import catalog from "./catalog.json" with { type: "json" };

const decoder = new TextDecoder();
const json = (value: unknown) => `${JSON.stringify(value, null, 2)}\n`;

async function run(command: string, args: string[], cwd?: string) {
  const result = await new Deno.Command(command, {
    args,
    cwd,
    env: cwd ? { NPM_CONFIG_CACHE: `${cwd}/cache` } : {},
  }).output();

  if (!result.success) {
    throw new Error(`${command}: ${decoder.decode(result.stderr).trim()}`);
  }

  return decoder.decode(result.stdout).trim();
}

export default defineSource(async () => {
  // Delay npm releases and dependencies by 24 hours; Git uses commit dates.
  const before = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const github = new Octokit({
    auth: Deno.env.get("GITHUB_TOKEN") ?? Deno.env.get("GH_TOKEN"),
  });

  const files: Record<string, string> = {};
  const manifest: Record<string, unknown> = {};

  for (const [source, plugin] of Object.entries(catalog)) {
    // Built-in bundles are already pinned by the host's package-lock.json.
    if ("bundled" in plugin && plugin.bundled) continue;

    if (source.startsWith("github:")) {
      const repository = source.slice("github:".length);
      const [owner, repo] = repository.split("/");
      const { data: commits } = await github.rest.repos.listCommits({
        owner,
        repo,
        sha: "branch" in plugin ? plugin.branch : undefined,
        until: before,
        per_page: 1,
      });
      if (!commits.length) {
        throw new Error(`${source}: no commit older than one day`);
      }

      const rev = commits[0].sha;
      const url = `https://codeload.github.com/${repository}/tar.gz/${rev}`;
      const { hash, storePath } = JSON.parse(
        await run("nix", [
          "store",
          "prefetch-file",
          "--unpack",
          "--json",
          url,
        ]),
      );

      const metadata = JSON.parse(
        await Deno.readTextFile(`${storePath}/package.json`),
      );
      if (
        !("packageName" in plugin) || metadata.name !== plugin.packageName ||
        !metadata.dsh?.bundle?.patch
      ) {
        throw new Error(`${source}: source is not the expected DSH bundle`);
      }

      if (
        Object.keys({
          ...metadata.dependencies,
          ...metadata.optionalDependencies,
        }).length
      ) {
        throw new Error(
          `${source}: Git bundle has runtime dependencies; add a locked build recipe`,
        );
      }

      manifest[source] = { version: metadata.version, rev, url, hash };
      continue;
    }

    if (!source.startsWith("npm:")) {
      throw new Error(`Unsupported DSH plugin source: ${source}`);
    }

    const packageName = source.slice("npm:".length);
    const directory = await Deno.makeTempDir({ prefix: "dsh-plugin-" });

    try {
      const packageJson = {
        name: "nix-repin-package",
        private: true,
        version: "1.0.0",
        dependencies: { [packageName]: "latest" },
      };

      await Deno.writeTextFile(`${directory}/package.json`, json(packageJson));
      await run("npm", [
        "install",
        "--package-lock-only",
        "--ignore-scripts",
        "--legacy-peer-deps",
        "--no-audit",
        "--no-fund",
        "--registry=https://registry.npmjs.org",
        `--before=${before}`,
      ], directory);

      const lock = JSON.parse(
        await Deno.readTextFile(`${directory}/package-lock.json`),
      );
      const resolved = lock.packages[`node_modules/${packageName}`];

      for (const [path, dependency] of Object.entries(lock.packages)) {
        if (path === "") continue;

        const entry = dependency as { resolved?: string; integrity?: string };
        if (
          !entry.resolved?.startsWith("https://registry.npmjs.org/") ||
          !entry.integrity
        ) {
          throw new Error(
            `${source}: ${path} must have a registry URL and integrity hash`,
          );
        }
      }

      packageJson.dependencies[packageName] = resolved.version;
      lock.packages[""].dependencies = packageJson.dependencies;
      await Deno.writeTextFile(`${directory}/package-lock.json`, json(lock));
      const npmDepsHash = await run("prefetch-npm-deps", [
        `${directory}/package-lock.json`,
      ]);

      manifest[source] = {
        version: resolved.version,
        url: resolved.resolved,
        integrity: resolved.integrity,
        npmDepsHash,
      };
      files[`locks/${packageName}/package.json`] = json(packageJson);
      files[`locks/${packageName}/package-lock.json`] = json(lock);
    } finally {
      await Deno.remove(directory, { recursive: true });
    }
  }

  return { ...files, "manifest.json": json(manifest) };
});
