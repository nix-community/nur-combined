#!/usr/bin/env bun
// Update versions.json with the latest Purpur build per Minecraft version.
//
// Usage:
//   bun ./update.ts            # fetch versions, update versions.json
//   ./update.ts                # same, via bun shebang (bun is in the dev shell)

import {
  downloadAndHash,
  fetchJson,
  isMcVersionSupported,
  loadVersions,
  writeVersions,
} from "../../scripts/update-lib.ts";

const BASE_URL = "https://api.purpurmc.org/v2/purpur";
const VERSIONS_PATH = `${import.meta.dir}/versions.json`;

interface VersionList {
  versions: string[];
}

interface VersionInfo {
  builds: {
    latest: string;
  };
}

interface CachedEntry {
  hash: string;
  version: string;
}

async function main(): Promise<void> {
  const existing = await loadVersions<CachedEntry>(VERSIONS_PATH);

  console.log("Fetching Purpur versions ...");
  const { versions } = await fetchJson<VersionList>(BASE_URL);
  const mcVersions = versions.filter(
    (v) => !v.includes("pre") && isMcVersionSupported(v),
  );

  const out: Record<string, CachedEntry> = {};
  for (const mc of mcVersions) {
    const info = await fetchJson<VersionInfo>(`${BASE_URL}/${mc}`);
    const build = info.builds.latest;
    const fullName = `${mc}-${build}`;
    const cached = existing[mc];
    if (cached && cached.version === fullName && cached.hash) {
      console.log(`Version ${fullName} already cached`);
      out[mc] = cached;
      continue;
    }
    const url = `${BASE_URL}/${mc}/${build}/download`;
    const hash = await downloadAndHash(url);
    console.log(`Version ${fullName} fetched`);
    out[mc] = { hash, version: fullName };
  }

  await writeVersions(VERSIONS_PATH, out);
}

await main();
