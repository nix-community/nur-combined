// The rule for pairing `sasso` with its prebuilt native addon.
//
// `sasso` declares the four `sasso-native-*` packages as EXACT-version
// `optionalDependencies`, so a plain `npm install sasso` is always aligned and
// this never fires. It fires when a consumer names those packages itself —
// then there are two places to bump and they can drift.
//
// A drift has to be refused rather than tolerated, because napi silently
// ignores config fields it does not know (measured on the addon at the time of
// writing: an unknown field compiles fine and returns CSS, no error, no
// warning). So an addon one release behind accepts every option the newer JS
// sends and applies only the ones it happens to recognise — the compile
// succeeds and quietly does something other than what was asked. A flag
// accepted that does nothing is the bug that opened momiji-rs/sasso#24; this
// is the same bug with no flag to blame it on. See #114.
//
// `nativeVersion()` from the addon cannot answer this: it reports
// `napi/Cargo.toml`'s version (`0.1.0`), which has nothing to do with the
// published package's. The platform package's own `package.json` does.

import { createRequire } from "node:module";

// Builtins through `require`, not `import`: an ESM import of `node:fs` builds
// its whole export facade, and reading every getter loads the stream stack
// with it (3.6 ms of a one-entry CLI compile, measured 2026-10-02; #272).
const require_ = createRequire(import.meta.url);

/**
 * Refuse a native addon whose version does not match this `sasso`.
 *
 * `ours`/`theirs` are versions read from the two `package.json` files, or
 * `null` where there is no manifest to read — the `SASSO_NATIVE_BINARY`
 * override and the repo-local `napi/npm/sasso.node` are development paths and
 * are deliberately not checked, since neither is a published pairing.
 *
 * Throws an `Error` carrying `code: "SASSO_ADDON_VERSION_MISMATCH"`, which the
 * CLI uses to tell a broken install apart from a platform with no prebuild.
 */
export function assertAddonVersion(ours, theirs, pkg) {
  if (!ours || !theirs || ours === theirs) return;
  const err = new Error(
    `sasso: the native addon is ${pkg}@${theirs}, but this is sasso@${ours}. ` +
      `They are released together and pinned to each other, so a mismatch means ` +
      `${pkg} was pinned separately from sasso. Refusing it: the addon ignores ` +
      `options it does not know without saying so, which would make newer options ` +
      `do nothing instead of failing. Drop any direct "${pkg}" dependency and let ` +
      `sasso pull it in, or set both to ${ours}.`,
  );
  err.code = "SASSO_ADDON_VERSION_MISMATCH";
  throw err;
}

// Which prebuilt platform package this machine needs.
//
// Here rather than in native.mjs because three callers need it — the loader
// resolves the addon from it, the CLI reports the engine it ended up on and
// warns when a platform that HAS a prebuild compiled through wasm anyway, and
// the tests have to build the same name to fabricate a skew. A second copy of
// this is exactly the kind of thing that drifts: the first version of the skew test spelled the key
// `${platform}-${arch}`, which is right on macOS and wrong on Linux — the
// prebuilds carry a libc suffix there — so the fabricated package was never
// resolved, the loader fell through to the repo-local build, and the test
// passed locally while asserting nothing on CI.
export const SUPPORTED = {
  "darwin-arm64": "sasso-native-darwin-arm64",
  "darwin-x64": "sasso-native-darwin-x64",
  "linux-x64-gnu": "sasso-native-linux-x64-gnu",
  "linux-arm64-gnu": "sasso-native-linux-arm64-gnu",
};

let key;

export function platformKey() {
  if (key === undefined) {
    const { platform, arch } = process;
    // glibc vs musl: the prebuilds are gnu-only for now.
    key = platform === "linux" ? `linux-${arch}-${isGlibc() ? "gnu" : "musl"}` : `${platform}-${arch}`;
  }
  return key;
}

/**
 * Whether this Linux runs glibc, asked of the system's `ldd` first.
 *
 * `process.report.getReport()` answers it exactly, but by building the whole
 * diagnostic report: 1.0–1.4 ms, and the CLI asked three times before every
 * compile (measured 2026-10-02, Linux/x86_64; #272). glibc's `ldd` is a
 * script that names "GNU C Library" and musl's names "musl", which is the
 * check `detect-libc` makes first; the report stays as the answer when the
 * file says neither or cannot be read.
 */
function isGlibc() {
  try {
    const ldd = require_("node:fs").readFileSync("/usr/bin/ldd", "latin1");
    if (ldd.includes("musl")) return false;
    if (ldd.includes("GNU C Library")) return true;
  } catch {
    // No readable `ldd`: fall through to the report.
  }
  return !!process.report?.getReport?.()?.header?.glibcVersionRuntime;
}

/**
 * The addon package prebuilt for this machine, or `null` where none is.
 *
 * The CLI asks this without loading anything: native.mjs throws at import time
 * when no addon loads, so it cannot be the one to answer "was there supposed
 * to be an addon here?" — which is what tells an ordinary wasm run apart from
 * a fallback worth warning about.
 */
export function nativePackage() {
  return SUPPORTED[platformKey()] ?? null;
}
