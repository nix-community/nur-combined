#!/usr/bin/env bun
// Update versions.json with the latest infinity-agent-cli release.
//
// Upstream cuts per-crate tags (infinity-agent-cli-v0.2.0, ...), so this
// tracks tags with that prefix and picks the highest semver. The
// models-dev provider lives in the ToyVo/infinity-provider-models-dev fork
// (plain v* tags) and is tracked the same way. Only version/tag/rev are
// resolved here; the nix hashes cannot be derived from the GitHub API, so
// a version bump resets them to the fake hash and you rehash with:
//
//   nix build '.#packages.<system>.infinity-agent-cli'   # repeat, pasting
//   each reported `got:` hash into versions.json (hash, npmUiHash,
//   npmWebHash, cargoHash — in that order) until the build goes green.
//   Do the same with .#packages.<system>.infinity-provider-models-dev
//   for modelsDev.hash / modelsDev.cargoHash.
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

interface ModelsDevVersions {
  version: string;
  tag: string;
  rev: string;
  hash: string;
  cargoHash: string;
}

interface VersionsFile {
  version: string;
  tag: string;
  rev: string;
  hash: string;
  cargoHash: string;
  npmUiHash: string;
  npmWebHash: string;
  modelsDev: ModelsDevVersions;
}

// infinity-provider-models-dev lives in a separate repo (ToyVo fork)
// with plain `v*` tags, tracked independently below.
const MODELS_DEV_OWNER = "ToyVo";
const MODELS_DEV_REPO = "infinity-provider-models-dev";
const MODELS_DEV_API_URL = `https://api.github.com/repos/${MODELS_DEV_OWNER}/${MODELS_DEV_REPO}/tags?per_page=100`;

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

  console.log(`Fetching tags from ${MODELS_DEV_OWNER}/${MODELS_DEV_REPO} ...`);
  const modelsDevTags = await fetchJson<GitHubTag[]>(MODELS_DEV_API_URL, {
    headers: githubHeaders("nixcfg-infinity-agent-cli-updater"),
  });
  const versionTags = modelsDevTags.filter((t) =>
    /^v\d+\.\d+\.\d+$/.test(t.name),
  );
  if (versionTags.length === 0) {
    throw new Error(
      `No v* tags found in ${MODELS_DEV_OWNER}/${MODELS_DEV_REPO}`,
    );
  }
  versionTags.sort((a, b) => compareVersions(a.name.slice(1), b.name.slice(1)));
  const latestModelsDev = versionTags[versionTags.length - 1];
  const modelsDevVersion = latestModelsDev.name.slice(1);
  console.log(
    `Latest models-dev tag: ${latestModelsDev.name} (${latestModelsDev.commit.sha})`,
  );

  const cached = await loadVersions<VersionsFile>(VERSIONS_PATH);
  let cliChanged =
    cached.version !== version || cached.rev !== latest.commit.sha;
  // Manual pin guard: the pinned rev may be ahead of the latest tag
  // (e.g. an unreleased upstream fix like the aws-config `sso` commit).
  // Never silently revert such a pin back to the tag; a newer tag release
  // containing the fix will show the pin as behind and update normally.
  // This only freezes the CLI fields — models-dev below still updates.
  if (cliChanged && cached.rev && cached.rev !== latest.commit.sha) {
    const cmp = await fetchJson<{ status: string }>(
      `https://api.github.com/repos/${OWNER}/${REPO}/compare/${latest.commit.sha}...${cached.rev}`,
      {
        headers: githubHeaders("nixcfg-infinity-agent-cli-updater"),
      },
    );
    if (cmp.status === "ahead" || cmp.status === "diverged") {
      console.log(
        `Pinned rev ${cached.rev} is ${cmp.status} of latest tag ${latest.name}; keeping CLI pin.`,
      );
      cliChanged = false;
    }
  }
  const modelsDevChanged =
    cached.modelsDev?.version !== modelsDevVersion ||
    cached.modelsDev?.rev !== latestModelsDev.commit.sha;
  if (!cliChanged && !modelsDevChanged) {
    console.log(`${version} already pinned, nothing to do`);
    return;
  }

  await writeVersions(VERSIONS_PATH, {
    version: cliChanged ? version : cached.version,
    tag: cliChanged ? latest.name : cached.tag,
    rev: cliChanged ? latest.commit.sha : cached.rev,
    hash: cliChanged ? FAKE_HASH : cached.hash,
    cargoHash: cliChanged ? FAKE_HASH : cached.cargoHash,
    npmUiHash: cliChanged ? FAKE_HASH : cached.npmUiHash,
    npmWebHash: cliChanged ? FAKE_HASH : cached.npmWebHash,
    modelsDev: {
      version: modelsDevVersion,
      tag: latestModelsDev.name,
      rev: latestModelsDev.commit.sha,
      hash: modelsDevChanged ? FAKE_HASH : cached.modelsDev.hash,
      cargoHash: modelsDevChanged ? FAKE_HASH : cached.modelsDev.cargoHash,
    },
  } satisfies VersionsFile);
  if (cliChanged)
    console.log(`hydro repo bumped to ${version}; hashes reset to fake.`);
  if (modelsDevChanged)
    console.log(
      `models-dev bumped to ${modelsDevVersion}; hashes reset to fake.`,
    );
  console.log(
    "Rehash with: nix build '.#packages.<system>.infinity-agent-cli',",
  );
  console.log(
    "pasting each `got:` hash into versions.json until the build is green, " +
      "then the same with .#packages.<system>.infinity-provider-models-dev.",
  );
}

await main();
