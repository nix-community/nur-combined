#!/usr/bin/env bun
// Update versions.json with the latest stable and beta Tinycast releases.
//
// Usage:
//   bun ./update.ts            # fetch latest releases, update versions.json
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

function stripV(tag: string): string {
  return tag.startsWith("v") ? tag.slice(1) : tag;
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
  const hash = await downloadAndHash(asset.browser_download_url, {
    headers: githubHeaders("nixcfg-tinycast-updater"),
  });
  console.log(`  ${version} hash from download: ${hash}`);
  return { version, hash };
}

async function main(): Promise<void> {
  console.log(`Fetching releases from ${OWNER}/${REPO} ...`);
  const releases = (
    await fetchJson<GitHubRelease[]>(API_URL, {
      headers: githubHeaders("nixcfg-tinycast-updater"),
    })
  ).filter((r) => !r.draft);
  // API returns newest first, so the first match is the latest.
  const stable = releases.find((r) => !r.prerelease);
  const beta = releases.find((r) => r.prerelease);
  if (!stable) throw new Error("No stable (non-prerelease) release found");
  if (!beta) throw new Error("No beta (prerelease) release found");

  const cached = await loadVersions<ChannelVersion>(VERSIONS_PATH);
  const cachedFile = cached as unknown as Partial<VersionsFile>;

  console.log(`Latest stable: ${stable.tag_name}`);
  const stableVersion = await resolveChannel(stable, cachedFile.stable);
  console.log(`Latest beta: ${beta.tag_name}`);
  const betaVersion = await resolveChannel(beta, cachedFile.beta);

  await writeVersions(VERSIONS_PATH, {
    stable: stableVersion,
    beta: betaVersion,
  } satisfies VersionsFile);
}

await main();
