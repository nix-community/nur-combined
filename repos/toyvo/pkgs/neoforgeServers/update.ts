#!/usr/bin/env bun
// Update versions.json with the latest NeoForge installer per Minecraft version.
//
// Upstream versions look like `21.5.97`, where the first two components map
// to Minecraft `1.21.5` and the full string is the installer build.
//
// Usage:
//   bun ./update.ts            # fetch versions, update versions.json
//   ./update.ts                # same, via bun shebang (bun is in the dev shell)

import {
  compareVersions,
  downloadAndHash,
  fetchJson,
  loadVersions,
  writeVersions,
} from "../../scripts/update-lib.ts";

const BASE_URL = "https://maven.neoforged.net";
const MIN_MINOR = 14;
const VERSIONS_PATH = `${import.meta.dir}/versions.json`;

interface MavenVersions {
  versions: string[];
}

interface CachedEntry {
  hash: string;
  version: string;
}

function toMcName(upstream: string): string | null {
  const match = /^(\d+)\.(\d+)\.(\d+)$/.exec(upstream);
  if (!match) return null;
  const minor = Number(match[1]);
  if (!Number.isInteger(minor) || minor < MIN_MINOR) return null;
  return `1.${match[1]}.${match[2]}`;
}

async function main(): Promise<void> {
  const existing = await loadVersions<CachedEntry>(VERSIONS_PATH);

  console.log("Fetching NeoForge versions ...");
  const { versions } = await fetchJson<MavenVersions>(
    `${BASE_URL}/api/maven/versions/releases/net/neoforged/neoforge`,
  );

  // Keep only the newest installer build per Minecraft version.
  const latest = new Map<string, { mc: string; build: string }>();
  for (const upstream of versions) {
    const mc = toMcName(upstream);
    if (!mc) continue;
    const prev = latest.get(mc);
    if (!prev || compareVersions(upstream, prev.build) > 0) {
      latest.set(mc, { mc, build: upstream });
    }
  }

  const out: Record<string, CachedEntry> = {};
  for (const { mc, build } of latest.values()) {
    const fullName = `${mc}-${build}`;
    const cached = existing[mc];
    if (cached && cached.version === fullName && cached.hash) {
      console.log(`Version ${fullName} already cached`);
      out[mc] = cached;
      continue;
    }
    const url = `${BASE_URL}/releases/net/neoforged/neoforge/${build}/neoforge-${build}-installer.jar`;
    const hash = await downloadAndHash(url);
    console.log(`Version ${fullName} fetched`);
    out[mc] = { hash, version: fullName };
  }

  await writeVersions(VERSIONS_PATH, out);
}

await main();
