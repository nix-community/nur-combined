#!/usr/bin/env bun
// Update versions.json with the latest nightly neovim release.
//
// Usage:
//   bun ./update.ts            # fetch nightly pin, update versions.json
//   ./update.ts                # same, via bun shebang (bun is in the dev shell)
//
// Auth (optional, raises GitHub API rate limits):
//   GITHUB_TOKEN=ghp_... bun ./update.ts
//
// Requires `nix` (for `nix flake prefetch`, which resolves the SRI hash of
// the git tree exactly as `fetchFromGitHub` will fetch it), so run inside
// `nix develop` when nix is not otherwise on PATH.

import {
  fetchJson,
  githubHeaders,
  writeVersions,
} from "../../scripts/update-lib.ts";

const OWNER = "neovim";
const REPO = "neovim";
const TAG = "nightly";
const VERSIONS_PATH = `${import.meta.dir}/versions.json`;

interface GitRef {
  ref: string;
  object: { sha: string; type: string; url: string };
}

interface GitTag {
  object: { sha: string; type: string };
}

interface GitHubRelease {
  tag_name: string;
  published_at: string;
}

interface NightlyPin {
  version: string;
  rev: string;
  hash: string;
}

/** Resolve the `nightly` tag to the commit sha it points at. */
async function nightlyRev(headers: Record<string, string>): Promise<string> {
  const [ref] = await fetchJson<GitRef[]>(
    `https://api.github.com/repos/${OWNER}/${REPO}/git/matching-refs/tags/${TAG}`,
    { headers },
  );
  if (!ref) throw new Error(`No git ref found for tags/${TAG}`);
  if (ref.object.type === "commit") return ref.object.sha;
  // Annotated tag: peel one level to the commit.
  const tag = await fetchJson<GitTag>(ref.object.url, { headers });
  if (tag.object.type !== "commit") {
    throw new Error(
      `tags/${TAG} does not resolve to a commit (got ${tag.object.type})`,
    );
  }
  return tag.object.sha;
}

/** The date (UTC) the nightly release was published, as YYYYMMDD. */
async function nightlyDate(headers: Record<string, string>): Promise<string> {
  const release = await fetchJson<GitHubRelease>(
    `https://api.github.com/repos/${OWNER}/${REPO}/releases/tags/${TAG}`,
    { headers },
  );
  const date = new Date(release.published_at);
  if (Number.isNaN(date.getTime())) {
    throw new Error(`Unexpected published_at: ${release.published_at}`);
  }
  return date.toISOString().slice(0, 10).replaceAll("-", "");
}

async function main(): Promise<void> {
  const headers = githubHeaders("nixcfg-toyvo-neovim-updater");

  console.log(`Resolving tags/${TAG} ...`);
  const rev = await nightlyRev(headers);
  console.log(`Latest nightly commit: ${rev}`);

  const cached: Partial<NightlyPin> = await Bun.file(VERSIONS_PATH)
    .json()
    .catch(() => ({}));
  if (cached.rev === rev && cached.hash && cached.version) {
    console.log(`${rev} unchanged, keeping cached pin`);
    return;
  }

  console.log("Prefetching git tree for the SRI hash ...");
  const proc = Bun.spawnSync(
    [
      "nix",
      "flake",
      "prefetch",
      "--json",
      `git+https://github.com/${OWNER}/${REPO}?rev=${rev}`,
    ],
    { stdout: "pipe", stderr: "pipe" },
  );
  if (proc.exitCode !== 0) {
    throw new Error(
      `nix flake prefetch failed: ${proc.stderr.toString().trim()}`,
    );
  }
  const { hash } = JSON.parse(proc.stdout.toString()) as { hash: string };
  if (!hash?.startsWith("sha256-")) {
    throw new Error(`Unexpected prefetch hash: ${hash}`);
  }
  console.log(`Hash: ${hash}`);

  const date = await nightlyDate(headers);
  const version = `nightly-${date}-g${rev.slice(0, 7)}`;
  console.log(`Version: ${version}`);

  const pin: NightlyPin = { version, rev, hash };
  await writeVersions(VERSIONS_PATH, pin);
}

await main();
