#!/usr/bin/env bun
// Update versions.json with the latest Ghostex release.
//
// Usage:
//   bun ./update.ts            # fetch latest release, update versions.json
//   ./update.ts                # same, via bun shebang (bun is in the dev shell)
//
// Auth (optional, raises GitHub API rate limits):
//   GITHUB_TOKEN=ghp_... bun ./update.ts

import {
  digestToSri,
  downloadAndHash,
  fetchJson,
  githubHeaders,
  loadVersions,
  writeVersions,
} from "../../scripts/update-lib.ts";

const OWNER = "maddada";
const REPO = "Ghostex";
const API_URL = `https://api.github.com/repos/${OWNER}/${REPO}/releases?per_page=100`;
const VERSIONS_PATH = `${import.meta.dir}/versions.json`;

// Upstream tags app releases `v<semver>` (e.g. v10.2.0). The releases feed
// also contains unrelated `code-server-*` snapshot releases, so the tag
// pattern — not just recency — selects the Ghostex release.
const TAG_PATTERN = /^v\d+\.\d+\.\d+$/;

// Release artifact per packaged nix system. Upstream ships no darwin-x64 dmg
// and no linux-arm64 desktop build, hence only these two systems.
const ASSETS: Record<string, (version: string) => string> = {
  "aarch64-darwin": (v) => `ghostex-${v}-arm64.dmg`,
  "x86_64-linux": (v) => `ghostex-${v}-linux-x64.tar.zst`,
};

interface GitHubAsset {
  name: string;
  browser_download_url: string;
  digest?: string | null;
}

interface GitHubRelease {
  tag_name: string;
  draft: boolean;
  prerelease: boolean;
  assets: GitHubAsset[];
}

interface SystemSource {
  file: string;
  hash: string;
}

interface VersionsFile {
  version: string;
  [system: string]: string | SystemSource;
}

function stripV(tag: string): string {
  return tag.startsWith("v") ? tag.slice(1) : tag;
}

async function resolveAsset(
  release: GitHubRelease,
  version: string,
  system: string,
  cached: SystemSource | undefined,
): Promise<SystemSource> {
  const file = ASSETS[system](version);
  const asset = release.assets.find((a) => a.name === file);
  if (!asset) {
    throw new Error(
      `Release ${release.tag_name} has no asset named ${file} (got: ${release.assets.map((a) => a.name).join(", ") || "none"})`,
    );
  }
  if (cached && cached.file === file && cached.hash) {
    console.log(`  ${system}: ${file} unchanged, keeping cached hash`);
    return cached;
  }
  if (asset.digest) {
    const hash = digestToSri(asset.digest);
    console.log(`  ${system}: ${file} hash from API digest: ${hash}`);
    return { file, hash };
  }
  console.log(
    `  no API digest for ${file}, downloading ${asset.browser_download_url} ...`,
  );
  const hash = await downloadAndHash(asset.browser_download_url, {
    headers: githubHeaders("nixcfg-ghostex-updater"),
  });
  console.log(`  ${system}: ${file} hash from download: ${hash}`);
  return { file, hash };
}

async function main(): Promise<void> {
  console.log(`Fetching releases from ${OWNER}/${REPO} ...`);
  const releases = (
    await fetchJson<GitHubRelease[]>(API_URL, {
      headers: githubHeaders("nixcfg-ghostex-updater"),
    })
  ).filter((r) => !r.draft && !r.prerelease && TAG_PATTERN.test(r.tag_name));
  // API returns newest first, so the first match is the latest.
  const latest = releases[0];
  if (!latest) throw new Error("No stable Ghostex (v<semver>) release found");
  const version = stripV(latest.tag_name);

  const cached = await loadVersions<SystemSource | string>(VERSIONS_PATH);

  console.log(`Latest release: ${latest.tag_name}`);
  const versions: VersionsFile = { version };
  for (const system of Object.keys(ASSETS)) {
    const prev = cached[system];
    versions[system] = await resolveAsset(
      latest,
      version,
      system,
      typeof prev === "object" ? (prev as SystemSource) : undefined,
    );
  }

  await writeVersions(VERSIONS_PATH, versions);
}

await main();
