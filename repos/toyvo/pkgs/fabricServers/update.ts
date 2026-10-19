#!/usr/bin/env bun
// Update versions.json with the latest Fabric loader/installer per Minecraft version.
//
// Usage:
//   bun ./update.ts            # fetch versions, update versions.json
//   ./update.ts                # same, via bun shebang (bun is in the dev shell)

import {
  compareVersions,
  fetchJson,
  downloadAndHash,
  isMcVersionSupported,
  loadVersions,
  writeVersions,
} from "../../scripts/update-lib.ts";

const BASE_URL = "https://meta.fabricmc.net/v2/versions";
const VERSIONS_PATH = `${import.meta.dir}/versions.json`;

interface GameVersion {
  version: string;
  stable: boolean;
}

interface LoaderOrInstaller {
  version: string;
  stable: boolean;
}

interface CachedEntry {
  hash: string;
  version: string;
}

function latestStable(entries: LoaderOrInstaller[], label: string): string {
  const stable = entries.filter((e) => e.stable).map((e) => e.version);
  if (stable.length === 0) throw new Error(`No stable ${label} versions found`);
  return stable.reduce((a, b) => (compareVersions(a, b) >= 0 ? a : b));
}

async function main(): Promise<void> {
  const existing = await loadVersions<CachedEntry>(VERSIONS_PATH);

  console.log("Fetching Minecraft versions ...");
  const game = await fetchJson<GameVersion[]>(`${BASE_URL}/game`);
  const mcVersions = game
    .filter((v) => v.stable)
    .map((v) => v.version)
    .filter((v) => isMcVersionSupported(v));

  console.log("Fetching latest loader ...");
  const loaders = await fetchJson<LoaderOrInstaller[]>(`${BASE_URL}/loader`);
  const loader = latestStable(loaders, "loader");
  console.log(`Latest loader: ${loader}`);

  console.log("Fetching latest installer ...");
  const installers = await fetchJson<LoaderOrInstaller[]>(
    `${BASE_URL}/installer`,
  );
  const installer = latestStable(installers, "installer");
  console.log(`Latest installer: ${installer}`);

  const versions: Record<string, CachedEntry> = {};
  for (const mc of mcVersions) {
    const fullName = `${mc}-${loader}-${installer}`;
    const cached = existing[mc];
    if (cached && cached.version === fullName && cached.hash) {
      console.log(`Version ${fullName} already cached`);
      versions[mc] = cached;
      continue;
    }
    const url = `${BASE_URL}/loader/${mc}/${loader}/${installer}/server/jar`;
    const hash = await downloadAndHash(url);
    console.log(`Version ${fullName} fetched`);
    versions[mc] = { hash, version: fullName };
  }

  await writeVersions(VERSIONS_PATH, versions);
}

await main();
