#!/usr/bin/env bun
// Update versions.json with the latest Ghostex release.
//
// Usage:
//   bun ./update.ts            # fetch latest release, update versions.json
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

function headers(): Record<string, string> {
  const headers: Record<string, string> = {
    Accept: "application/vnd.github+json",
    "User-Agent": "nixcfg-ghostex-updater",
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

/** Fallback when the API provides no digest: download the artifact and hash it. */
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
  const hash = await downloadAndHash(asset.browser_download_url);
  console.log(`  ${system}: ${file} hash from download: ${hash}`);
  return { file, hash };
}

async function main(): Promise<void> {
  console.log(`Fetching releases from ${OWNER}/${REPO} ...`);
  const releases = (await fetchReleases()).filter(
    (r) => !r.draft && !r.prerelease && TAG_PATTERN.test(r.tag_name),
  );
  // API returns newest first, so the first match is the latest.
  const latest = releases[0];
  if (!latest) throw new Error("No stable Ghostex (v<semver>) release found");
  const version = stripV(latest.tag_name);

  let cached: Partial<VersionsFile> = {};
  try {
    cached = (await Bun.file(VERSIONS_PATH).json()) as Partial<VersionsFile>;
  } catch {
    console.log("No existing versions.json, fetching all hashes");
  }

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

  await Bun.write(VERSIONS_PATH, `${JSON.stringify(versions, null, 2)}\n`);
  console.log(`Wrote ${VERSIONS_PATH}`);
}

await main();
