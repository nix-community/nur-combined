// sasso/binary — where the native `sasso` command-line binary is, for a tool
// that spawns the compiler and wants to skip node.
//
// The prebuilt platform package (`sasso-native-<target>`, the optional
// dependency that also carries the addon) ships the release binary beside
// it. A process that spawns `node_modules/.bin/sasso` starts node first, and
// node alone takes about as long as dart-sass takes to compile a small entry:
// one entry was 38.3 ms through the npm CLI and 4.3 ms through the binary
// (Linux/x86_64, measured 2026-10-02; #272). Nothing here runs at install
// time — no install script, so no package manager has to approve one — and
// nothing uses the binary unless a caller asks for its path.

import { createRequire } from "node:module";
import { assertAddonVersion, platformKey, SUPPORTED } from "./_addon.mjs";

// `require`, not `import`, for `node:fs`: see `require_` in _addon.mjs.
const require_ = createRequire(import.meta.url);
const { existsSync, readFileSync } = require_("node:fs");
const { dirname, join } = require_("node:path");

function ownVersion() {
  try {
    return JSON.parse(readFileSync(new URL("./package.json", import.meta.url), "utf8")).version ?? null;
  } catch {
    return null;
  }
}

/**
 * The absolute path of the `sasso` binary prebuilt for this machine, or
 * `null` where there is none: a platform with no prebuild (Windows, musl,
 * anything but the four in `_addon.mjs`), an install that skipped optional
 * dependencies, or a platform package from before the binary shipped in it.
 *
 * Throws, with `code: "SASSO_ADDON_VERSION_MISMATCH"`, when the platform
 * package carries a binary but is a different version from this `sasso` —
 * the same refusal the native addon makes, for the same reason: the two are
 * released together, and a binary of another version accepts a different
 * set of flags.
 */
export function binaryPath() {
  const pkg = SUPPORTED[platformKey()];
  if (!pkg) return null;
  let manifest;
  try {
    manifest = require_.resolve(`${pkg}/package.json`);
  } catch {
    return null;
  }
  // Presence first: a platform package from before the binary shipped is
  // usually an OLDER one too, and with nothing to hand out there is nothing a
  // version mismatch could make wrong. The pairing is checked only for a
  // binary this would actually return.
  const bin = join(dirname(manifest), "sasso");
  if (!existsSync(bin)) return null;
  let theirs = null;
  try {
    theirs = JSON.parse(readFileSync(manifest, "utf8")).version ?? null;
  } catch {
    // No readable manifest: nothing to compare, so nothing to refuse.
  }
  assertAddonVersion(ownVersion(), theirs, pkg);
  return bin;
}

export default { binaryPath };
