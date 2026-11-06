#!/usr/bin/env bun
// Update versions.json with the latest infinity-agent-cli release.
//
// Upstream cuts per-crate tags (infinity-agent-cli-v0.2.0, ...), so this
// tracks tags with that prefix and picks the highest semver. Only
// version/tag/rev are resolved here; the nix hashes (src, cargo, both npm
// caches) cannot be derived from the GitHub API, so a version bump resets
// them to the fake hash and you rehash with:
//
//   nix build '.#packages.<system>.infinity-agent-cli'   # repeat, pasting
//   each reported `got:` hash into versions.json (hash, npmUiHash,
//   npmWebHash, cargoHash — in that order) until the build goes green.
//
// Usage:
//   bun ./update.ts            # fetch latest tags, update versions.json
//   ./update.ts                # same, via bun shebang (bun is in the dev shell)
//
// Auth (optional, raises GitHub API rate limits):
//   GITHUB_TOKEN=ghp_... bun ./update.ts

import {
  compareVersions,
  fetchJson,
  githubHeaders,
  loadVersions,
  writeVersions,
} from "../../scripts/update-lib.ts";

const OWNER = "hydro-project";
const REPO = "infinity";
const TAG_PREFIX = "infinity-agent-cli-v";
const API_URL = `https://api.github.com/repos/${OWNER}/${REPO}/tags?per_page=100`;
const VERSIONS_PATH = `${import.meta.dir}/versions.json`;
const FAKE_HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

interface GitHubTag {
  name: string;
  commit: { sha: string };
}

interface VersionsFile {
  version: string;
  tag: string;
  rev: string;
  hash: string;
  cargoHash: string;
  npmUiHash: string;
  npmWebHash: string;
}

async function main(): Promise<void> {
  console.log(`Fetching tags from ${OWNER}/${REPO} ...`);
  const tags = await fetchJson<GitHubTag[]>(API_URL, {
    headers: githubHeaders("nixcfg-infinity-agent-cli-updater"),
  });
  const cliTags = tags.filter((t) => t.name.startsWith(TAG_PREFIX));
  if (cliTags.length === 0) {
    throw new Error(`No tags with prefix ${TAG_PREFIX} found`);
  }
  cliTags.sort((a, b) =>
    compareVersions(
      a.name.slice(TAG_PREFIX.length),
      b.name.slice(TAG_PREFIX.length),
    ),
  );
  const latest = cliTags[cliTags.length - 1];
  const version = latest.name.slice(TAG_PREFIX.length);
  console.log(`Latest tag: ${latest.name} (${latest.commit.sha})`);

  const cached = await loadVersions<VersionsFile>(VERSIONS_PATH);
  if (cached.version === version && cached.rev === latest.commit.sha) {
    console.log(`${version} already pinned, nothing to do`);
    return;
  }

  await writeVersions(VERSIONS_PATH, {
    version,
    tag: latest.name,
    rev: latest.commit.sha,
    hash: FAKE_HASH,
    cargoHash: FAKE_HASH,
    npmUiHash: FAKE_HASH,
    npmWebHash: FAKE_HASH,
  } satisfies VersionsFile);
  console.log(`versions.json bumped to ${version}; hashes reset to fake.`);
  console.log(
    "Rehash with: nix build '.#packages.<system>.infinity-agent-cli',",
  );
  console.log(
    "pasting each `got:` hash into versions.json until the build is green.",
  );
}

await main();
