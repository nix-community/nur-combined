#!/usr/bin/env bun
// Update versions.json with every stable Vintage Story server release.
//
// Usage:
//   bun ./update.ts            # fetch versions, update versions.json
//   ./update.ts                # same, via bun shebang (bun is in the dev shell)

import {
  downloadAndHash,
  fetchJson,
  loadVersions,
  writeVersions,
} from "../../scripts/update-lib.ts";

const BASE_URL = "https://api.vintagestory.at";
const VERSIONS_PATH = `${import.meta.dir}/versions.json`;

interface StableEntry {
  linuxserver?: { urls: { cdn: string } };
  server?: { urls: { cdn: string } };
}

interface CachedEntry {
  hash: string;
  url: string;
}

async function main(): Promise<void> {
  const existing = await loadVersions<CachedEntry>(VERSIONS_PATH);

  console.log("Fetching Vintage Story versions ...");
  const stable = await fetchJson<Record<string, StableEntry>>(
    `${BASE_URL}/stable.json`,
  );

  const out: Record<string, CachedEntry> = {};
  for (const [name, entry] of Object.entries(stable)) {
    console.log(`Fetching version ${name}`);
    const url = entry.linuxserver?.urls.cdn ?? entry.server?.urls.cdn;
    if (!url) {
      console.log(`  no server download for version ${name}, skipping`);
      continue;
    }
    const cached = existing[name];
    if (cached && cached.url === url && cached.hash) {
      console.log(`Version ${name} already cached`);
      out[name] = cached;
      continue;
    }
    const hash = await downloadAndHash(url);
    console.log(`Version ${name} fetched`);
    out[name] = { hash, url };
  }

  await writeVersions(VERSIONS_PATH, out);
}

await main();
