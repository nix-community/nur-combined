#!/usr/bin/env bun
// Shared helpers for the per-package `update.ts` scripts in `pkgs/*/`.
//
// Each updater fetches upstream release metadata, reuses cached SRI hashes
// from its sibling `versions.json` when the upstream version is unchanged,
// downloads artifacts only when needed, and rewrites `versions.json`.
//
// Usage in an updater:
//   import {
//     downloadAndHash,
//     loadVersions,
//     writeVersions,
//     ...
//   } from "../../scripts/update-lib.ts";

import { createHash } from "node:crypto";

export interface FetchJsonOptions {
  /** Per-request timeout in ms (default 60_000). Passed-through callers
      that already set `init.signal` keep their own signal. */
  timeoutMs?: number;
}

/** Fetch a URL and parse the response as JSON, throwing on HTTP errors. */
export async function fetchJson<T>(
  url: string,
  init?: RequestInit,
  opts: FetchJsonOptions = {},
): Promise<T> {
  const { timeoutMs = 60_000 } = opts;
  const withTimeout = init?.signal
    ? init
    : { ...init, signal: AbortSignal.timeout(timeoutMs) };
  const res = await fetch(url, withTimeout);
  if (!res.ok) {
    throw new Error(
      `Failed to fetch ${url} (${res.status} ${res.statusText}): ${await res.text()}`,
    );
  }
  return (await res.json()) as T;
}

/** Convert a hex-encoded sha256 to an SRI hash (`sha256-<base64>`) for fetchurl. */
export function sriFromHex(hex: string): string {
  if (!hex || !/^[0-9a-fA-F]+$/.test(hex)) {
    throw new Error(`Unexpected hex digest: ${hex}`);
  }
  return `sha256-${Buffer.from(hex, "hex").toString("base64")}`;
}

/**
 * Convert a `sha256:<hex>` digest (as reported by the GitHub releases API)
 * to an SRI hash for fetchurl.
 */
export function digestToSri(digest: string): string {
  const hex = digest.split(":", 2)[1];
  if (!hex || !/^[0-9a-fA-F]+$/.test(hex)) {
    throw new Error(`Unexpected digest format: ${digest}`);
  }
  return sriFromHex(hex);
}

export function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export interface DownloadAndHashOptions {
  headers?: Record<string, string>;
  /** How many attempts before giving up (default 5). */
  retries?: number;
  /** Delay between attempts in ms (default 10_000). */
  retryDelayMs?: number;
  /** Per-attempt timeout in ms (default 600_000). Bounds stalled
      connections so one stuck download can't pin a CI runner; the
      retry loop still applies afterwards. */
  timeoutMs?: number;
}

/**
 * Download a URL and return its SRI hash (`sha256-<base64>`), streaming the
 * body so large artifacts never fully sit in memory. Retries on failure
 * (the Vintage Story CDN is flaky enough that the old Python updater
 * retried forever — we retry a bounded number of times instead).
 */
export async function downloadAndHash(
  url: string,
  opts: DownloadAndHashOptions = {},
): Promise<string> {
  const {
    headers,
    retries = 5,
    retryDelayMs = 10_000,
    timeoutMs = 600_000,
  } = opts;
  let lastError: unknown;
  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const res = await fetch(url, {
        headers,
        signal: AbortSignal.timeout(timeoutMs),
      });
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
    } catch (e) {
      lastError = e;
      if (attempt < retries) {
        console.log(
          `  download failed (attempt ${attempt}/${retries}): ${e}. Retrying in ${retryDelayMs / 1000}s ...`,
        );
        await sleep(retryDelayMs);
      }
    }
  }
  throw lastError instanceof Error
    ? lastError
    : new Error(`Failed to download ${url}: ${lastError}`);
}

/**
 * Load the existing `versions.json` cache. Returns `{}` when the file is
 * missing or unparseable (first run).
 */
export async function loadVersions<T>(
  versionsPath: string,
): Promise<Record<string, T>> {
  try {
    return (await Bun.file(versionsPath).json()) as Record<string, T>;
  } catch {
    console.log("No existing versions.json, fetching all hashes");
    return {};
  }
}

/** Write `versions.json` with 2-space indent and a trailing newline. */
export async function writeVersions(
  versionsPath: string,
  versions: unknown,
): Promise<void> {
  await Bun.write(versionsPath, `${JSON.stringify(versions, null, 2)}\n`);
  console.log(`Wrote ${versionsPath}`);
}

/**
 * Minecraft version gate used by the game-server updaters: keep versions
 * newer than `1.<minMinor>`, plus any major version above 1 (e.g. the new
 * `26.x` versioning scheme Paper/Purpur/Fabric adopted).
 */
export function isMcVersionSupported(version: string, minMinor = 14): boolean {
  const parts = version.split(".");
  if (parts.length < 2) return false;
  const major = Number(parts[0]);
  const minor = Number(parts[1]);
  if (!Number.isInteger(major) || !Number.isInteger(minor)) return false;
  return major > 1 || (major === 1 && minor >= minMinor);
}

/** Numeric dot-separated version comparison (e.g. loader `0.16.9` strings). */
export function compareVersions(a: string, b: string): number {
  const pa = a.split(".").map(Number);
  const pb = b.split(".").map(Number);
  for (let i = 0; i < Math.max(pa.length, pb.length); i++) {
    const diff = (pa[i] ?? 0) - (pb[i] ?? 0);
    if (diff !== 0) return diff;
  }
  return 0;
}

/** Return the highest version in the list according to `compareVersions`. */
export function latestBySemver(versions: string[]): string {
  if (versions.length === 0) throw new Error("No versions to choose from");
  return versions.reduce((a, b) => (compareVersions(a, b) >= 0 ? a : b));
}

/**
 * Headers for the GitHub releases API. Honors `GITHUB_TOKEN` when set to
 * raise the rate limit, matching the tinycast/ghostex updaters.
 *
 * Detects and discards Forgejo tokens which are invalid for api.github.com
 * to prevent 401 Unauthorized errors.
 */
export function githubHeaders(userAgent: string): Record<string, string> {
  const headers: Record<string, string> = {
    Accept: "application/vnd.github+json",
    "User-Agent": userAgent,
    "X-GitHub-Api-Version": "2022-11-28",
  };
  const token = process.env.GITHUB_TOKEN;
  if (token) {
    // Forgejo tokens are invalid for api.github.com and cause 401s.
    // GitHub tokens start with ghp_, gho_, ghu_, ghs_, or github_pat_.
    // Forgejo tokens typically don't match these patterns.
    const isLikelyGitHubToken = /^(ghp_|gho_|ghu_|ghs_|github_pat_)/.test(
      token,
    );
    if (isLikelyGitHubToken) {
      headers.Authorization = `Bearer ${token}`;
    }
    // If it's not a recognizable GitHub token pattern, we skip it
    // to avoid sending invalid credentials that cause 401s.
  }
  return headers;
}
