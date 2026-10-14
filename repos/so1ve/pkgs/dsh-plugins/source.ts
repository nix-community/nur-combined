import { defineSource, github, npm } from "nix-repin";
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
    const lockPath = `${directory}/package-lock.json`;

    try {
      const packageJson = {
        name: "nix-repin-package",
        private: true,
        version: "1.0.0",
        dependencies: { [packageName]: "latest" },
      };

      await Deno.writeTextFile(`${directory}/package.json`, json(packageJson));
      await npm.writeLock(directory, { before, legacyPeerDeps: true });

      const lock = JSON.parse(await Deno.readTextFile(lockPath));

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
      await Deno.writeTextFile(lockPath, lockContents);
      const npmDepsHash = await npm.hash(lockPath);

      manifest[source] = { version, url, integrity, npmDepsHash };
      files[`locks/${packageName}/package.json`] = json(packageJson);
      files[`locks/${packageName}/package-lock.json`] = lockContents;
    } finally {
      await Deno.remove(directory, { recursive: true });
    }
  }

  files["manifest.json"] = json(manifest);

  return files;
});
