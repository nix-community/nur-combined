import * as fs from "node:fs/promises";
import { defineSource, github, npm, tempDir } from "nix-repin";
import catalog from "./catalog.json" with { type: "json" };

const json = (value: unknown) => `${JSON.stringify(value, null, 2)}\n`;

export default defineSource(async () => {
  // Delay npm releases and dependencies by 24 hours; Git uses commit dates.
  const before = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const files: Record<string, string> = {};
  const manifest: Record<string, unknown> = {};

  for (const [source, plugin] of Object.entries(catalog)) {
    // Built-in bundles are already pinned by the host's package-lock.json.
    if ("bundled" in plugin && plugin.bundled) continue;

    if (source.startsWith("github:")) {
      const repository = source.slice("github:".length);
      const { rev } = await github.latestCommit({
        repository,
        branch: "branch" in plugin ? plugin.branch : undefined,
        before,
      });
      const { url, hash, storePath } = await github.prefetchArchive(
        repository,
        rev,
      );

      const metadata = JSON.parse(
        await fs.readFile(`${storePath}/package.json`, "utf8"),
      );
      if (
        !("packageName" in plugin) || metadata.name !== plugin.packageName ||
        !metadata.dsh?.bundle?.patch
      ) {
        throw new Error(`${source}: source is not the expected DSH bundle`);
      }

      const npmDepsHash = await npm.hash(`${storePath}/package-lock.json`);
      manifest[source] = {
        version: metadata.version,
        rev,
        url,
        hash,
        npmDepsHash,
      };
      continue;
    }

    if (!source.startsWith("npm:")) {
      throw new Error(`Unsupported DSH plugin source: ${source}`);
    }

    const packageName = source.slice("npm:".length);
    await using tmp = await tempDir("dsh-plugin-");
    const lockPath = `${tmp.path}/package-lock.json`;

    const packageJson = {
      name: "nix-repin-package",
      private: true,
      version: "1.0.0",
      dependencies: { [packageName]: "latest" },
    };

    await fs.writeFile(`${tmp.path}/package.json`, json(packageJson));
    await npm.writeLock(tmp.path, { before, legacyPeerDeps: true });

    const lock = JSON.parse(await fs.readFile(lockPath, "utf8"));

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

    const { version, resolved: url, integrity } =
      lock.packages[`node_modules/${packageName}`];
    packageJson.dependencies[packageName] = version;
    lock.packages[""].dependencies = packageJson.dependencies;
    const lockContents = json(lock);
    await fs.writeFile(lockPath, lockContents);
    const npmDepsHash = await npm.hash(lockPath);

    manifest[source] = { version, url, integrity, npmDepsHash };
    files[`locks/${packageName}/package.json`] = json(packageJson);
    files[`locks/${packageName}/package-lock.json`] = lockContents;
  }

  files["manifest.json"] = json(manifest);

  return files;
});
