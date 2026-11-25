import * as fs from "node:fs/promises";
import * as path from "node:path";
import { defineSource } from "nix-repin";
import {
  fetchGitHubCommitArchive,
  formatJson,
} from "../../lib/plugin-sources.ts";
import catalog from "./catalog.json" with { type: "json" };

interface PluginManifest {
  id?: unknown;
  name?: unknown;
  version?: unknown;
  main?: unknown;
}

export default defineSource(async () => {
  const manifest: Record<string, unknown> = {};

  for (const [name, plugin] of Object.entries(catalog)) {
    const { rev, date, url, hash, storePath } = await fetchGitHubCommitArchive({
      repository: plugin.repository,
      branch: "branch" in plugin && typeof plugin.branch === "string"
        ? plugin.branch
        : undefined,
    });

    const metadata = JSON.parse(
      await fs.readFile(path.join(storePath, "plugin.json"), "utf8"),
    ) as PluginManifest;

    if (
      typeof metadata.id !== "string" || metadata.id.length === 0 ||
      typeof metadata.name !== "string" || metadata.name.length === 0
    ) {
      throw new Error(`${name}: plugin.json must define string id and name`);
    }

    const entry = typeof metadata.main === "string" && metadata.main.length > 0
      ? metadata.main
      : "index.js";
    await fs.access(path.join(storePath, entry));

    const version =
      typeof metadata.version === "string" && metadata.version.length > 0
        ? metadata.version
        : `0-unstable-${date}`;

    manifest[name] = {
      id: metadata.id,
      version,
      rev,
      url,
      hash,
    };
  }

  return {
    "manifest.json": formatJson(manifest),
  };
});
