#!/usr/bin/env bun
// Update versions.json with the latest stable and beta Tinycast releases.
//
// Usage:
//   bun ./update.ts            # fetch latest releases, update versions.json
//   ./update.ts                # same, via bun shebang (bun is in the dev shell)
//
// NOTE: intentionally not a nix-shell shebang like the update.py scripts.
// The two-line `#!/usr/bin/env nix-shell` + `#!nix-shell -i ...` form only
// works when `#` starts a comment (e.g. Python) — bun rejects line 2 as a
// syntax error. The single-line alternatives are broken too: nix-shell no
// longer accepts `-i` on the command line, and `nix shell nixpkgs#bun -c`
// cannot be a shebang because `#` is stripped as a comment in the exec path.
//
// Auth (optional, raises GitHub API rate limits):
//   GITHUB_TOKEN=ghp_... bun ./update.ts

import { createHash } from "node:crypto";

const OWNER = "abue-ammar";
const REPO = "tinycast";
const API_URL = `https://api.github.com/repos/${OWNER}/${REPO}/releases?per_page=100`;
const VERSIONS_PATH = `${import.meta.dir}/versions.json`;

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

interface ChannelVersion {
  version: string;
  hash: string;
}

interface VersionsFile {
  stable: ChannelVersion;
  beta: ChannelVersion;
}

function headers(): Record<string, string> {
  const headers: Record<string, string> = {
    Accept: "application/vnd.github+json",
    "User-Agent": "nixcfg-tinycast-updater",
    "X-GitHub-Api-Version": "2022-11-28",
  };
  const token = process.env.GITHUB_TOKEN;
  if (token) headers.Authorization = `Bearer ${token}`;
  return headers;
}

async function fetchReleases(): Promise<GitHubRelease[]> {
  const res = await fetch(API_URL, { headers: headers() });
  if (!res.ok) {
    throw new Error(
      `Failed to fetch releases (${res.status} ${res.statusText}): ${await res.text()}`,
    );
  }
  return (await res.json()) as GitHubRelease[];
}

function stripV(tag: string): string {
  return tag.startsWith("v") ? tag.slice(1) : tag;
}

/** Convert a `sha256:<hex>` digest (as reported by the GitHub releases API) to an SRI hash for fetchurl. */
function digestToSri(digest: string): string {
  const hex = digest.split(":", 2)[1];
  if (!hex || !/^[0-9a-fA-F]+$/.test(hex)) {
    throw new Error(`Unexpected digest format: ${digest}`);
  }
  return `sha256-${Buffer.from(hex, "hex").toString("base64")}`;
}

/** Fallback when the API provides no digest: download the dmg and hash it. */
async function downloadAndHash(url: string): Promise<string> {
  const res = await fetch(url, { headers: headers() });
  if (!res.ok || !res.body) {
    throw new Error(
      `Failed to download ${url}: ${res.status} ${res.statusText}`,
    );
  }
  const hash = createHash("sha256");
  for await (const chunk of res.body as unknown as AsyncIterable<Uint8Array>) {
    hash.update(chunk);
  }
  return `sha256-${hash.digest("base64")}`;
}

async function resolveChannel(
  release: GitHubRelease,
  cached: ChannelVersion | undefined,
): Promise<ChannelVersion> {
  const version = stripV(release.tag_name);
  const assetName = `Tinycast-${version}.dmg`;
  const asset = release.assets.find((a) => a.name === assetName);
  if (!asset) {
    throw new Error(
      `Release ${release.tag_name} has no asset named ${assetName} (got: ${release.assets.map((a) => a.name).join(", ") || "none"})`,
    );
  }
  if (cached && cached.version === version && cached.hash) {
    console.log(`  ${version} unchanged, keeping cached hash`);
    return cached;
  }
  if (asset.digest) {
    const hash = digestToSri(asset.digest);
    console.log(`  ${version} hash from API digest: ${hash}`);
    return { version, hash };
  }
  console.log(
    `  no API digest for ${assetName}, downloading ${asset.browser_download_url} ...`,
  );
  const hash = await downloadAndHash(asset.browser_download_url);
  console.log(`  ${version} hash from download: ${hash}`);
  return { version, hash };
}

async function main(): Promise<void> {
  console.log(`Fetching releases from ${OWNER}/${REPO} ...`);
  const releases = (await fetchReleases()).filter((r) => !r.draft);
  // API returns newest first, so the first match is the latest.
  const stable = releases.find((r) => !r.prerelease);
  const beta = releases.find((r) => r.prerelease);
  if (!stable) throw new Error("No stable (non-prerelease) release found");
  if (!beta) throw new Error("No beta (prerelease) release found");

  let cached: Partial<VersionsFile> = {};
  try {
    cached = (await Bun.file(VERSIONS_PATH).json()) as Partial<VersionsFile>;
  } catch {
    console.log("No existing versions.json, fetching all hashes");
  }

  console.log(`Latest stable: ${stable.tag_name}`);
  const stableVersion = await resolveChannel(stable, cached.stable);
  console.log(`Latest beta: ${beta.tag_name}`);
  const betaVersion = await resolveChannel(beta, cached.beta);

  const versions: VersionsFile = { stable: stableVersion, beta: betaVersion };
  await Bun.write(VERSIONS_PATH, `${JSON.stringify(versions, null, 2)}\n`);
  console.log(`Wrote ${VERSIONS_PATH}`);
}

await main();
