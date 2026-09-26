#!/usr/bin/env node
// sasso CLI — `npx sasso input.scss [output.css]`. Pure Node, no dependencies
// of its own: it compiles through the native addon when the platform package
// is installed and the wasm build otherwise (see `loadEngine`), and spreads
// independent jobs over `node:worker_threads`.
// A subset of the dart-sass `sass` CLI flags, sharing the package's compiler.
import {
  readFileSync,
  writeFileSync,
  writeSync,
  watch,
  statSync,
  existsSync,
  readdirSync,
  mkdirSync,
  realpathSync,
  readlinkSync,
  rmSync,
  openSync,
  readSync,
  closeSync,
  accessSync,
  constants as fsConstants,
} from "node:fs";
import { basename, dirname, join, resolve, relative, sep, delimiter } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { isMainThread, workerData, parentPort, Worker } from "node:worker_threads";
import { spawnSync } from "node:child_process";
import { constants as osConstants } from "node:os";
// The pool's default size — physical cores rather than SMT threads on Linux,
// where `/proc/cpuinfo` publishes the topology, and the CPU count everywhere
// else. See _jobs.mjs for the measurement and for both fallbacks.
import { defaultJobs } from "./_jobs.mjs";
// The accepted deprecation ids, shared with the JS API so there is one copy.
import { DEPRECATION_IDS } from "./_deprecations.mjs";
import { triggersRecompile } from "./_watchfilter.mjs";
import { coalesce } from "./_coalesce.mjs";
import { makeProbe } from "./_probe.mjs";
import { makePoller } from "./_poller.mjs";
import { baselineFor } from "./_baseline.mjs";
import { makeWatchers } from "./_watchers.mjs";
import { errorCss } from "./_errorcss.mjs";
// One UTF-8 rule for every read. `readFileSync(fd, "utf8")` substitutes
// U+FFFD instead of refusing, which is the bug this exists to prevent.
import { decodeUtf8 } from "./_importer.mjs";
// The prebuilt-addon rules, shared with native.mjs: which engine this platform
// is SUPPOSED to run decides whether a wasm fallback is news (see `loadEngine`).
import { nativePackage, platformKey } from "./_addon.mjs";

/**
 * The engine, chosen at startup rather than imported statically.
 *
 * `sasso-native-<platform>` is an `optionalDependency`, so `npm install sasso`
 * already fetched the native addon on the four prebuilt targets — it is the
 * same compiler as the wasm build, byte-identical in output (`napi/test.mjs`
 * asserts that), and about 2.2x the throughput. Everywhere else the wasm build
 * takes over, and the CLI picks the SPEED variant of it: a command line has
 * none of the download-size pressure that makes `sasso.mjs` the right default
 * for a bundled web build.
 *
 * `SASSO_ENGINE=wasm|native` forces one, which is what the tests use to hold
 * both to the same output.
 */
let compile, compileString, Exception, Logger;

/**
 * How this process chose its engine, for `--engine` and for the fallback
 * warning. The choice was completely unobservable before: an install whose
 * addon did not land compiled at roughly half the throughput and said nothing,
 * so answering "which engine am I on?" took bisecting the install
 * (momiji-rs/sasso#24).
 */
const engine = { kind: null, requested: undefined, platform: null, addon: null, error: null, refused: false };

async function loadEngine() {
  const want = process.env.SASSO_ENGINE;
  engine.requested = want;
  engine.platform = platformKey();
  engine.addon = nativePackage();
  let mod;
  let kind = "native";
  if (want !== "wasm") {
    try {
      mod = await import("./native.mjs");
    } catch (e) {
      // Through the same coerced string in both places: a `throw null` or a
      // thrown string from anything native.mjs imports has no `.message`, and
      // reading it would replace the load failure with a TypeError.
      engine.error = e && e.message ? String(e.message) : String(e);
      // `fail` writes synchronously, which matters because it exits at once.
      // A refused addon is a different answer from a missing one: it WAS found
      // and rejected. Kept apart so the report names which happened, and so
      // the generic fallback warning does not repeat what is said just below.
      engine.refused = e?.code === "SASSO_ADDON_VERSION_MISMATCH";
      if (want === "native") fail(`error: SASSO_ENGINE=native but the addon is unavailable: ${engine.error}`);
      // An ABSENT addon is the ordinary case on the platforms with no prebuild,
      // and falling back to wasm is the whole design — it says nothing. An
      // addon that is present but version-skewed is a broken install: wasm
      // keeps the OUTPUT correct, so the build still succeeds, but staying
      // quiet would trade a wrong compile for a slow one with nothing to read.
      if (engine.refused) {
        writeStderrSync(`warning: ${engine.error}\nwarning: falling back to the wasm engine, which is slower.\n`);
      }
    }
  }
  if (!mod) {
    mod = await import("./sasso.speed.mjs");
    kind = "wasm";
  }
  ({ compile, compileString, Exception, Logger } = mod);
  engine.kind = kind;
  return kind;
}

/** Why `engine.kind` and not the other one, in one clause. */
function engineReason() {
  if (engine.requested === "wasm" || engine.requested === "native") return `forced by SASSO_ENGINE=${engine.requested}`;
  // "the native addon", not "the prebuilt addon": `SASSO_NATIVE_BINARY` and a
  // repo checkout both load one that no platform package delivered.
  if (engine.kind === "native") return "the default here: the native addon loaded";
  if (engine.refused) return "FELL BACK: the prebuilt addon was refused (its version does not match sasso)";
  if (engine.addon) return "FELL BACK: a prebuilt addon exists for this platform but did not load";
  return "the default here: no addon is prebuilt for this platform";
}

/** `--engine`: the whole engine decision, in a form an issue can be pasted into. */
function engineReport() {
  const lines = [];
  // The hand-off first, because with a release binary on PATH the honest answer
  // to "which engine am I on?" is "none of them" — and when there is no binary,
  // `handoff.why` says what was in the way, which is the question that follows.
  if (handoff.path) lines.push(`binary:   ${handoff.path} — every compile is handed to it (${handoff.why})`);
  else if (handoff.why) lines.push(`binary:   not used — ${handoff.why}`);
  lines.push(
    `engine:   ${engine.kind === "native" ? "native (Node addon)" : "wasm (speed build)"} — ${engineReason()}` +
      (handoff.path ? " (unused while the binary above is there)" : ""),
    `platform: ${engine.platform}${engine.addon ? ` (prebuilt addon: ${engine.addon})` : " (no prebuilt addon)"}`,
  );
  // Only ever set when loading the addon was TRIED and failed, so this is the
  // one line that separates "never installed" from "installed but unloadable"
  // — the question the silent fallback used to swallow. First line only: a
  // `SASSO_NATIVE_BINARY` miss carries Node's whole require stack, and one
  // `key: value` per line is what makes this output pasteable.
  if (engine.error) lines.push(`addon:    did not load: ${engine.error.split("\n")[0]}`);
  lines.push(`sasso:    ${packageVersion()}`);
  return lines.join("\n") + "\n";
}

/**
 * A two-line warning on stderr — what happened, then what to do about it — when
 * a platform that HAS a prebuilt addon compiled through wasm anyway. That is an
 * install accident (`--omit=optional`, a partial lockfile, an unloadable addon),
 * not a supported configuration, and it costs roughly half the throughput.
 *
 * Four ways it stays quiet, each for its own reason. `SASSO_ENGINE=wasm` states
 * the intent, so a fallback is not news. A platform with no prebuild is RUNNING
 * its supported engine, and a warning nobody can act on is noise. A refused
 * addon has already been reported by `loadEngine`, in more detail and with the
 * fix in it. And `--quiet` means "don't print warnings" — dart's contract,
 * which this CLI keeps to the letter (stderr is empty under `-q`, asserted);
 * `--engine` is then the way to ask, and it answers whatever the flags say.
 *
 * Once per run, from the main thread: every worker loads its own engine, so
 * warning there would print this per core.
 */
function warnIfFellBack(opts) {
  if (opts.quiet) return;
  if (engine.kind !== "wasm" || engine.requested === "wasm" || !engine.addon) return;
  // A version skew already printed the same fact with the fix in it (#115).
  if (engine.refused) return;
  writeStderrSync(
    `sasso: WARNING: ${engine.addon} is prebuilt for this platform but did not load, so this run ` +
      `compiles through wasm — roughly half the throughput.\n` +
      `sasso: run \`sasso --engine\` for the reason, or set SASSO_ENGINE=wasm to choose wasm silently.\n`,
  );
}

/**
 * The release binary, when this CLI should hand it the whole command line
 * rather than compile in-process.
 *
 * Same compiler, same flags, byte-identical output — but this package pays
 * Node's start-up and then moves every file's source and CSS across the napi
 * boundary, and the binary pays neither. Measured on 40 entry points with
 * `--style=compressed --no-source-map`, published artifacts, macOS/arm64, one
 * run for the whole set (2026-09-18): the binary 15.1 ms, this CLI on the
 * native addon 104.1 ms, this CLI delegating 48.2 ms. So a `brew install`ed
 * sasso sitting beside `npm install sasso` was ~7x the throughput of the one
 * npm reached for, which is what momiji-rs/sasso#24 asked us to stop wasting,
 * and handing it the command line recovers 2.2x of it. What is left is Node
 * itself: 35.0 ms of the 48.2 is start-up and the spawn (the same delegated
 * command line on ONE tiny file), which is why this is a hand-off and not a
 * faster engine.
 *
 * `SASSO_BINARY`:
 *   - unset                  auto: a `sasso` on PATH whose version matches
 *                            this package EXACTLY is used, and anything else
 *                            is passed over silently.
 *   - a path                 use that binary, version unchecked — explicit is
 *                            explicit, and it is how you drive an unreleased
 *                            build.
 *   - 0 / off / false / no   never delegate. Empty counts as unset.
 * `SASSO_ENGINE=wasm|native` also turns delegation off: it demands a specific
 * in-process engine, and a subprocess is not one.
 *
 * The version gate is the whole safety story for the automatic case. Without
 * it, a project pinning `sasso` in its devDependencies would silently compile
 * with whatever sasso happens to be on a developer's PATH. That is #114 —
 * a version-skewed addon loaded anyway, quietly dropping options it could not
 * apply — one process further out, where it is harder to see.
 */
const NEVER_DELEGATE = new Set(["0", "off", "false", "no"]);

/** Set on the child, so a `sasso` on PATH that is really this CLI cannot loop. */
const DELEGATE_MARK = "SASSO_CLI_DELEGATED";

/**
 * What `pickBinary` decided, in the same words twice: `SASSO_DEBUG_ENGINE`
 * prints it as it happens and `--engine` reports it afterwards. One string, so
 * the two can never disagree about why a binary was or was not used.
 */
const handoff = { path: null, why: null };

function engineDebug(msg) {
  if (process.env.SASSO_DEBUG_ENGINE) writeStderrSync(`sasso: ${msg}\n`);
}

/** Compile here, and remember what was in the way. */
function compileInProcess(why) {
  handoff.why = why;
  engineDebug(`compiling in-process: ${why}`);
  return undefined;
}

/** Hand `path` the command line, and remember why it was the right one. */
function handTo(path, why) {
  handoff.path = path;
  handoff.why = why;
  engineDebug(`handing the command line to ${path}: ${why}`);
  return path;
}

/**
 * True for a real executable image, false for a script.
 *
 * `npm install -g sasso` puts a `sasso` on PATH that IS this file behind a
 * `#!/usr/bin/env node` line, so a PATH lookup finds it and delegating to it
 * would fork bomb. Refusing anything that is not a native image rules that out
 * structurally rather than by guessing from the path, and also declines shell
 * wrappers, whose exit codes and stdio we would not control.
 * (`DELEGATE_MARK` still backs this up for a wrapper reached some other way.)
 */
function isNativeImage(path) {
  let fd;
  try {
    fd = openSync(path, "r");
    const head = Buffer.alloc(4);
    if (readSync(fd, head, 0, 4, 0) < 4) return false;
    const magic = head.readUInt32BE(0);
    return (
      magic === 0x7f454c46 || // ELF
      magic === 0xcffaedfe || // Mach-O 64, little-endian (arm64/x86_64 macOS)
      magic === 0xcefaedfe || // Mach-O 32
      magic === 0xcafebabe || // Mach-O universal
      magic === 0xcafebabf || // Mach-O universal, 64-bit
      // PE/COFF ("MZ"). Untested: no CI job has ever run on Windows (#85).
      head.readUInt16BE(0) === 0x4d5a
    );
  } catch {
    return false;
  } finally {
    if (fd !== undefined) closeSync(fd);
  }
}

/**
 * The first executable native `sasso` on PATH, or undefined.
 *
 * An empty `PATH` entry means the current directory to a POSIX shell, and is
 * skipped here on purpose: this lookup decides who receives the project's whole
 * command line, and honouring it would let a checkout with a `sasso` beside its
 * `package.json` be handed it. The divergence only ever finds FEWER binaries
 * than the shell would, and not finding one costs nothing but speed — the
 * in-process engine compiles the same bytes. `SASSO_BINARY=./sasso` is how to
 * ask for one there deliberately.
 */
function sassoOnPath() {
  const names = process.platform === "win32" ? ["sasso.exe", "sasso"] : ["sasso"];
  for (const dir of (process.env.PATH || "").split(delimiter)) {
    if (!dir) continue;
    for (const name of names) {
      const candidate = join(dir, name);
      try {
        accessSync(candidate, fsConstants.X_OK);
      } catch {
        continue;
      }
      if (isNativeImage(candidate)) return candidate;
    }
  }
  return undefined;
}

/**
 * The binary's version, or undefined if it does not identify itself as sasso.
 *
 * `sasso --version` prints exactly `sasso <version>` and nothing else
 * (src/main.rs: one `println!`), where this CLI prints a bare `<version>`,
 * dart's format. The WHOLE output has to be that line — not its last field, and
 * not its first line either: this is the gate that decides whether a stranger
 * gets the project's command line, and something else installed as `sasso` can
 * print a version too. Reading only the last field would accept
 * `some-other-tool 0.16.0`, and reading only the first line would accept
 * anything that leads with a plausible one.
 */
function binaryVersion(path) {
  const r = spawnSync(path, ["--version"], { encoding: "utf8", timeout: 10000 });
  if (r.error || r.status !== 0) return undefined;
  const m = /^sasso (\S+)$/.exec(String(r.stdout || "").trim());
  return m ? m[1] : undefined;
}

/**
 * The binary to hand this command line to, or undefined to compile in-process.
 *
 * `opts` is already parsed, so `--help`/`--version` have exited in `parseArgs`
 * and still answer from this file alone: a metadata question must not start
 * depending on a subprocess any more than it depended on a compiler.
 */
function pickBinary(opts) {
  if (process.env[DELEGATE_MARK]) return compileInProcess(`${DELEGATE_MARK} is set: this process IS the hand-off`);

  const wantEngine = process.env.SASSO_ENGINE;
  if (wantEngine === "wasm" || wantEngine === "native") {
    return compileInProcess(`SASSO_ENGINE=${wantEngine} demands an in-process engine`);
  }

  const want = process.env.SASSO_BINARY;
  if (want !== undefined && want !== "" && NEVER_DELEGATE.has(want.toLowerCase())) {
    return compileInProcess("SASSO_BINARY declines the binary");
  }

  // `--watch` stays here, and since #86 that is a CHOICE rather than the
  // binary lacking a watcher. It has one, and it polls, because a native
  // watcher would be a runtime dependency in a crate whose `[dependencies]`
  // is empty.
  //
  // Measured on macOS, one SETTLED save per process, twelve fresh
  // processes, median: this CLI 34 ms, the binary 45 ms, dart-sass 1.104.1
  // 13196 ms. Handing off would trade the fastest of the three for the
  // second.
  //
  // The previous version of this comment said 18-20/13-55/47-51 ms
  // "measured on one save", and one save is the whole error: the number it
  // caught was a catch-up compile reading the file, not an event arriving.
  // The real event latency was a ~1s median with a 7s tail (#164).
  if (opts.watch) return compileInProcess("--watch is faster in-process than the binary's poll");
  // `--update` is no longer on that list: the binary has it, and walks the
  // same dependency graph this CLI does. It is still held back from the
  // EXPLICIT `SASSO_BINARY=<path>` hand-off below, which is documented as
  // version-unchecked and may well name a binary from before the flag
  // existed; the version-matched hand-off further down cannot, because a
  // binary of this version has it by construction.
  const updateNeedsMatch = opts.update;

  if (want !== undefined && want !== "") {
    if (!isNativeImage(want)) fail(`error: SASSO_BINARY=${want} is not an executable sasso binary`);
    if (updateNeedsMatch) {
      return compileInProcess(`--update with SASSO_BINARY=${want}, whose version is unchecked`);
    }
    return handTo(want, `SASSO_BINARY=${want}, version unchecked`);
  }

  const found = sassoOnPath();
  if (!found) return compileInProcess("no sasso binary on PATH");
  const theirs = binaryVersion(found);
  const ours = packageVersion();
  // Silent by default: a mismatch is a normal state of the world, not a problem
  // to interrupt a build over. `--engine` is where to go and ask.
  if (theirs === undefined) {
    return compileInProcess(`${found} does not answer --version with \`sasso <version>\``);
  }
  if (theirs !== ours) {
    return compileInProcess(`${found} is ${theirs}, this package is ${ours}`);
  }
  return handTo(found, `the same version as this package, ${theirs}`);
}

/** Run the binary in our place. Never returns. */
function delegate(path) {
  const r = spawnSync(path, process.argv.slice(2), {
    stdio: "inherit",
    env: { ...process.env, [DELEGATE_MARK]: "1" },
  });
  if (r.error) fail(`error: could not run ${path}: ${r.error.message}`);
  if (r.signal) {
    // Report a killed child the way a shell does, rather than flattening every
    // signal into 1: ^C during a big build should read as 130, not as a
    // compile failure.
    const n = osConstants.signals[r.signal];
    process.exit(n ? 128 + n : 1);
  }
  process.exit(r.status === null ? 1 : r.status);
}

const HELP = `sasso — compile SCSS/Sass to CSS

Usage: sasso [options] <input.scss> [output.css]
       sasso [options] <input.scss>:<output.css> [<in>:<out> ...]
       sasso [options] <in-dir>:<out-dir>
       sasso [options] <dir>                 (compiles the tree in place)
       sasso [options] --stdin [output.css]
       cat a.scss | sasso --stdin

Options:
  -s, --style <expanded|compressed>  Output style (default: expanded).
  -I, --load-path <dir>              Add a load path for @use/@import (repeatable).
  -o, --output <file>                Write the CSS to <file> (the same as a
                                     second positional argument).
      --stdin                        Read the stylesheet from standard input.
      --indented                     Parse stdin as the indented .sass syntax.
      --[no-]source-map              Emit a source map (default: on when writing
                                     to a file, off for stdout).
      --embed-sources                Embed source text in the map's sourcesContent.
      --embed-source-map             Embed the source map as a data: URI in the CSS.
      --[no-]charset                 Emit @charset/BOM for non-ASCII output
                                     (default: on).
      --source-map-urls <relative|absolute>
                                     How the map references its sources
                                     (default: relative).
  -q, --[no-]quiet                   Suppress @warn / @debug / deprecation output.
      --silence-deprecation <IDS>    Don't print these deprecations
                                     (comma-separated; repeatable).
      --[no-]quiet-deps              Drop deprecation warnings raised inside
                                     dependencies: stylesheets reached through
                                     a load path, and whatever those load
                                     relatively. Their own @warn/@debug still
                                     prints, as in dart-sass.
      --[no-]stop-on-error           Don't compile more files once an error is
                                     encountered.
      --[no-]error-css               On a compile error, write a stylesheet
                                     describing it (default: on when compiling
                                     to a file).
      --no-css                       Compile but discard the CSS: no output
                                     file, no stdout, and an existing output is
                                     left exactly as it was.
      --update                       Leave outputs already newer than their input
                                     and every stylesheet it loads.
  -w, --watch                        Recompile when the input or any dependency
                                     changes (requires <input> <output>).
  -j, --jobs <N>                     Compile at most N files at once
                                     (default: one per core, or per CPU
                                     where the core count is unknown).
      --loop <N>                     Recompile in-process N times and report
                                     throughput (stdout inputs only).
  -c, --[no-]color                   Accepted for compatibility (no-op: output is
                                     never colored).
      --[no-]unicode                 Unicode box glyphs in diagnostics
                                     (default: on).
  -h, --help                         Print this help.
      --version                      Print the version.
      --engine                       Print what this install compiles with and
                                     why: a sasso binary it hands the command
                                     line to, or its own engine (native addon
                                     or wasm).

An <in>:<out> pair may name DIRECTORIES: every .scss/.sass/.css file under
<in> that is not a partial compiles to the matching path under <out>.
Symlinked directories are followed, each one only once.

With no output file the CSS is written to stdout. A Sass error is printed to
stderr and exits non-zero.`;

/** The version npm installed: the `version` of the package.json beside this file. */
function packageVersion() {
  try {
    return JSON.parse(readFileSync(new URL("./package.json", import.meta.url), "utf8")).version;
  } catch {
    return "unknown";
  }
}

/**
 * The `sysexits` codes dart-sass uses, which the native CLI already
 * follows (`EXIT_USAGE`/`EXIT_COMPILE`/`EXIT_IO` in `src/main.rs`).
 *
 * Measured 2026-09-22 against dart-sass 1.104.1 and the binary, every
 * failure shape, all three agreeing except this CLI:
 *
 *   compile error            dart 65   binary 65   npm 1
 *   missing import           dart 65   binary 65   npm 1
 *   input does not exist     dart 66   binary 66   npm 1
 *   output is a directory    dart 66   binary 66   npm 1
 *   usage error              dart 64   binary 64   npm 1
 *   a batch with both        dart 66   binary 66   npm 1
 *
 * A build script that switches on the code to tell "your stylesheet is
 * wrong" from "I could not write where you told me" got neither from the
 * package advertised as a drop-in.
 */
const EXIT_USAGE = 64;
const EXIT_COMPILE = 65;
const EXIT_IO = 66;

/**
 * `code` defaults to a USAGE error because nearly every caller is one: a
 * flag that does not exist, a combination dart refuses, a pair with two
 * colons in it. The exceptions pass their own.
 */
function fail(msg, code = EXIT_USAGE) {
  writeStderrSync(String(msg).replace(/\n?$/, "\n"));
  process.exit(code);
}

// One shared cell, only ever used to sleep a millisecond (see below).
const idle = new Int32Array(new SharedArrayBuffer(4));

/**
 * Write to stderr and do not come back until the OS has it.
 *
 * `process.stderr.write` on a PIPE is asynchronous and `process.exit` throws
 * away whatever has not reached the kernel: a 480 KB error came out of
 * `sasso huge.scss 2>&1 | cat` as exactly 131072 bytes, every run, while the
 * same error redirected to a file was whole (measured 2026-09-17). A caller
 * that exits immediately afterwards therefore cannot use the stream.
 *
 * A full pipe raises EAGAIN rather than blocking, because Node puts stdio
 * pipes in non-blocking mode; that means the reader is behind, so wait a
 * moment and continue. EPIPE means there is no reader left to tell.
 */
function writeStderrSync(text) {
  writeFdSync(2, text);
}

/**
 * The same, to an arbitrary descriptor. Used for the error stylesheet on
 * stdout, which `fail()` follows with `process.exit` — and an
 * asynchronous write to a pipe has no promise of draining first. It does
 * not truncate here (measured: 480 KB through a pipe, twelve runs,
 * complete every time, so Node is flushing), which makes this insurance
 * rather than a fix. It costs nothing and it makes both streams behave
 * the same way, which is the reason `writeStderrSync` exists at all.
 */
function writeFdSync(fd, text) {
  const bytes = Buffer.from(text, "utf8");
  let at = 0;
  while (at < bytes.length) {
    try {
      at += writeSync(fd, bytes, at, bytes.length - at);
    } catch (e) {
      if (e.code === "EAGAIN") {
        Atomics.wait(idle, 0, 0, 1);
        continue;
      }
      if (e.code === "EPIPE") return;
      throw e;
    }
  }
}

function parseArgs(argv) {
  const opts = {
    style: "expanded",
    loadPaths: [],
    stdin: false,
    indented: false,
    sourceMap: undefined, // tri-state: default depends on output target
    embedSources: false,
    embedSourceMap: false,
    charset: true,
    errorCss: undefined,
    quiet: false,
    quietDeps: false,
    silenceDeprecations: [],
    stopOnError: false,
    noCss: false,
    // Tri-state: dart's default is "relative", but only an EXPLICIT
    // --source-map-urls is rejected when printing to stdout.
    sourceMapUrls: undefined,
    update: false,
    jobs: undefined,
    watch: false,
    unicode: true,
    loop: undefined,
    output: undefined,
    printEngine: false,
    positionals: [],
  };
  for (let i = 0; i < argv.length; i++) {
    let a = argv[i];
    const takeValue = (inline) => {
      if (inline !== undefined) return inline;
      const v = argv[++i];
      if (v === undefined) fail(`error: ${a} requires a value`);
      return v;
    };
    if (a === "--") {
      opts.positionals.push(...argv.slice(i + 1));
      break;
    } else if (a === "-h" || a === "--help") {
      process.stdout.write(HELP + "\n");
      process.exit(0);
    } else if (a === "--version") {
      // The PACKAGE's version, from the package.json beside this file — not
      // parsed out of an engine's `info`, which names the ENGINE crate: the
      // native addon reports `(sasso-native <ver>)`, the old regex missed it,
      // and the fallback printed the second field — dart's compatibility
      // version — as if it were ours.
      process.stdout.write(`${packageVersion()}\n`);
      process.exit(0);
    } else if (a === "--engine") {
      // Not answered here, unlike `--version`: the answer IS which engine loads,
      // so it is the one metadata question that has to load one. `main` prints
      // it after `loadEngine`, so a demanded-but-missing engine still fails
      // loudly there rather than reporting a fallback it did not take.
      opts.printEngine = true;
    } else if (a === "--stdin") {
      opts.stdin = true;
    } else if (a === "--no-stdin") {
      opts.stdin = false;
    } else if (a === "-w" || a === "--watch") {
      opts.watch = true;
    } else if (a === "--poll" || a === "--no-poll") {
      // dart chooses between a native watcher and repeated stats with
      // this, and so do we now. The default is BOTH: `fs.watch` for
      // latency and a sweep beside it for the guarantee, because on macOS
      // the watcher delivers a median of 552ms and drops events outright
      // (#164, and the table in `_poller.mjs`).
      //
      //   --poll      sweep only, no native watcher — dart's meaning
      //   --no-poll   native watcher only, which is what this CLI did
      //               before #164 and what Linux alone can afford
      //
      // The binary has no `[dependencies]` to give it a native watcher,
      // so it polls either way and the flag stays a no-op there.
      opts.poll = a === "--poll";
    } else if (a === "--indented") {
      opts.indented = true;
    } else if (a === "--no-indented") {
      opts.indented = false;
    } else if (a === "--source-map") {
      opts.sourceMap = true;
    } else if (a === "--no-source-map") {
      opts.sourceMap = false;
    } else if (a === "--embed-sources") {
      opts.embedSources = true;
    } else if (a === "--no-embed-sources") {
      opts.embedSources = false;
    } else if (a === "--embed-source-map") {
      opts.embedSourceMap = true;
    } else if (a === "--no-embed-source-map") {
      opts.embedSourceMap = false;
    } else if (a === "-q" || a === "--quiet") {
      opts.quiet = true;
    } else if (a === "--no-quiet") {
      opts.quiet = false;
    } else if (a === "--quiet-deps") {
      opts.quietDeps = true;
    } else if (a === "--no-quiet-deps") {
      opts.quietDeps = false;
    } else if (a === "--stop-on-error") {
      opts.stopOnError = true;
    } else if (a === "--no-stop-on-error") {
      opts.stopOnError = false;
    } else if (a === "--no-css") {
      opts.noCss = true;
    } else if (a === "--update") {
      opts.update = true;
    } else if (a === "--charset") {
      opts.charset = true;
    } else if (a === "--no-charset") {
      opts.charset = false;
      // `--error-css` is implemented (see `reportFailure`); `--color` is a
      // no-op in the native CLI too, so it is one here. (`--jobs` is no
      // longer in this company: it caps the worker pool — see `runJobs`.)
    } else if (a === "--error-css") {
      opts.errorCss = true;
    } else if (a === "--no-error-css") {
      opts.errorCss = false;
    } else if (a === "-c" || a === "--color" || a === "--no-color") {
      // no-op: output is never colored
    } else if (a === "--unicode") {
      opts.unicode = true;
    } else if (a === "--no-unicode") {
      opts.unicode = false;
    } else if (a === "-j" || a === "--jobs" || a.startsWith("--jobs=") || (a.startsWith("-j") && a.length > 2)) {
      let inline;
      if (a.startsWith("--jobs=")) inline = a.slice(7);
      else if (a.startsWith("-j") && a.length > 2) inline = a.slice(2);
      opts.jobs = positiveInt("--jobs", takeValue(inline), USIZE_MAX);
    } else if (a === "--loop" || a.startsWith("--loop=")) {
      opts.loop = positiveInt("--loop", takeValue(a.startsWith("--loop=") ? a.slice(7) : undefined), U32_MAX);
    } else if (a === "--source-map-urls" || a.startsWith("--source-map-urls=")) {
      const inline = a.startsWith("--source-map-urls=") ? a.slice(18) : undefined;
      const v = takeValue(inline);
      if (v !== "relative" && v !== "absolute") fail(`error: unknown --source-map-urls "${v}"`);
      opts.sourceMapUrls = v;
    } else if (a === "-o" || a === "--output" || a.startsWith("--output=")) {
      const inline = a.startsWith("--output=") ? a.slice(9) : undefined;
      // Repeating it is an assignment, as in the native parser: the last one
      // wins. (Naming the output twice in DIFFERENT ways — `-o` plus a second
      // positional — is the error, and `validate` catches that.)
      opts.output = takeValue(inline);
    } else if (a === "-s" || a === "--style" || a.startsWith("--style=")) {
      const inline = a.startsWith("--style=") ? a.slice(8) : undefined;
      const v = takeValue(inline);
      if (v !== "expanded" && v !== "compressed") fail(`error: unknown style "${v}"`);
      opts.style = v;
    } else if (a === "--silence-deprecation" || a.startsWith("--silence-deprecation=")) {
      const inline = a.startsWith("--silence-deprecation=") ? a.slice(22) : undefined;
      const v = takeValue(inline);
      if (!v) fail("error: --silence-deprecation requires a value");
      for (const raw of v.split(",")) {
        const id = raw.trim();
        // dart rejects an unknown id rather than ignoring it, so a typo is
        // caught instead of quietly leaving the warning in place.
        if (!DEPRECATION_IDS.has(id)) fail(`error: Invalid deprecation "${id}".`);
        if (!opts.silenceDeprecations.includes(id)) opts.silenceDeprecations.push(id);
      }
    } else if (a === "-I" || a === "--load-path" || a.startsWith("--load-path=") || a.startsWith("-I")) {
      let inline;
      if (a.startsWith("--load-path=")) inline = a.slice(12);
      else if (a.startsWith("-I") && a.length > 2) inline = a.slice(2);
      opts.loadPaths.push(takeValue(inline));
    } else if (a.startsWith("-") && a !== "-" && !a.startsWith("-:")) {
      // `-` is standard input and `-:out.css` is a pair reading it, so neither
      // is an unknown option (the native CLI carves out the same two).
      fail(`error: unknown option ${a}`);
    } else {
      opts.positionals.push(a);
    }
  }
  validate(opts);
  return opts;
}

/**
 * A positive integer, or the native CLI's rejection of what was passed. The
 * token itself has to be a decimal integer, as Rust's `parse` requires:
 * `Number()` would take `1.0`, `1e3`, `0x2` and whitespace-padded values that
 * the native CLI refuses (`+3` and `03` it accepts, and so does this). `max` is
 * the Rust integer type the native parser uses, so a value that overflows there
 * is rejected here too rather than starting work nobody can wait for —
 * `--loop=4294967296` overflows a `u32` and would otherwise run four billion
 * compiles.
 */
function positiveInt(flag, value, max) {
  const digits = /^\+?[0-9]+$/.test(value);
  const n = digits ? BigInt(value) : 0n;
  if (!digits || n < 1n || n > max) {
    fail(`error: ${flag} expects a positive integer (got ${JSON.stringify(value)})`);
  }
  return Number(n);
}

/** `u32::MAX` and `usize::MAX`, the widths `parse_loop` and `parse_jobs` use. */
const U32_MAX = 4294967295n;
const USIZE_MAX = 18446744073709551615n;

/**
 * The combinations the native CLI rejects before compiling anything (dart-sass
 * rejects the source-map and arity ones with the same wording): the positional
 * grammar is `<input> [output]`, `--output` names ONE output, source-map flags
 * need a source map, and a map printed to stdout can only be an embedded one
 * with absolute sources.
 */
function validate(opts) {
  const operands = opts.positionals;
  const pairs = operands.some((a) => colonIndex(a) >= 0);

  // Checked in the native parser's order, so a command line that trips two
  // rules reports the same one there and here.
  if (opts.sourceMap === false) {
    if (opts.embedSourceMap) fail("error: --embed-source-map isn't allowed with --no-source-map.");
    if (opts.embedSources) fail("error: --embed-sources isn't allowed with --no-source-map.");
    if (opts.sourceMapUrls !== undefined) fail("error: --source-map-urls isn't allowed with --no-source-map.");
  }
  // dart: `--update is not allowed with --stdin.` Standard input has no mtime,
  // so "is the output newer than its input" has no honest answer. This CLI
  // happened to do the safe thing (statting `-` throws, so nothing looked
  // fresh) while the binary did the dangerous one; refusing the pair is what
  // dart does and leaves neither to luck.
  if (opts.update && opts.stdin) fail("error: --update is not allowed with --stdin.");
  // dart: `--watch is not allowed with --stdin.` and `--poll may not be
  // passed without --watch.`, both exit 64 (measured against 1.104.1 on
  // 2026-09-20). The binary refuses the same two with the same wording.
  if (opts.watch && opts.stdin) fail("error: --watch is not allowed with --stdin.");
  if (opts.poll !== undefined && !opts.watch) fail("error: --poll may not be passed without --watch.");
  if (pairs) {
    if (!operands.every((a) => colonIndex(a) >= 0)) {
      fail('error: Positional and ":" arguments may not both be used.');
    }
    if (opts.stdin) fail('error: --stdin may not be used with ":" arguments.');
    if (opts.output !== undefined) fail('error: --output may not be used with ":" arguments.');
  } else if (opts.stdin) {
    if (operands.length > 1) fail("error: Only one argument is allowed with --stdin.");
    // With --stdin the single positional IS the output, so naming both it and
    // --output is the same mistake as `<input> <output> --output`.
    if (opts.output !== undefined && operands.length > 0) fail("error: --output requires a single input");
  } else {
    if (operands.length > 2) fail("error: Only two positional args may be passed.");
    if (opts.output !== undefined && operands.length > 1) fail("error: --output requires a single input");
  }

  // The output, however it was named: `--output`, the second positional, or
  // the one positional `--stdin` takes.
  const namedOutput = opts.output !== undefined ? opts.output : pairs ? undefined : operands[opts.stdin ? 0 : 1];
  if (opts.loop !== undefined) {
    // --loop measures the compiler, so it compiles to stdout, once per
    // iteration, with no source map to build and no warnings to print.
    if (pairs || namedOutput !== undefined) {
      fail('error: --loop compiles to stdout only (no ":" arguments or --output).');
    }
    if (!opts.stdin && operands.length === 1 && isDirectory(operands[0])) {
      fail('error: --loop compiles to stdout only (no directories, ":" arguments or --output).');
    }
    if (opts.sourceMap === true || opts.embedSourceMap || opts.embedSources) {
      fail(
        "error: --loop does not generate source maps (drop --source-map, --embed-source-map and --embed-sources).",
      );
    }
  }
  // A directory may not be the OUTPUT. (The `--stdin` path does not go through
  // `parseJobs`, so checking there alone left it to fail as an uncaught EISDIR
  // from `writeFileSync`.)
  if (namedOutput !== undefined && isDirectory(namedOutput)) {
    fail(`error: Directory "${namedOutput}" may not be a positional arg.`);
  }
  // A bare directory entry (`sasso src`) compiles to files, not to stdout.
  const toStdout =
    !pairs &&
    namedOutput === undefined &&
    (opts.stdin || operands.length === 0 || !isDirectory(operands[0]));
  if (!toStdout) return;
  if (opts.sourceMapUrls === "relative") {
    fail("error: --source-map-urls=relative isn't allowed when printing to stdout.");
  }
  if (opts.embedSourceMap) return;
  if (opts.sourceMap === true) {
    fail("error: When printing to stdout, --source-map requires --embed-source-map.");
  }
  if (opts.embedSources) {
    fail("error: When printing to stdout, --embed-sources requires --embed-source-map.");
  }
  if (opts.sourceMapUrls !== undefined) {
    fail("error: When printing to stdout, --source-map-urls requires --embed-source-map.");
  }
}

/** Raw standard input. An unreadable fd is empty input, as a closed pipe is. */
function readStdinBytes() {
  try {
    return readFileSync(0); // fd 0, bytes — "utf8" would substitute U+FFFD
  } catch {
    return Buffer.alloc(0);
  }
}

/**
 * Standard input as text.
 *
 * Invalid UTF-8 is an entry failure, not a string with replacement
 * characters in it. A file entry throws `Error: Invalid UTF-8.`
 * (`readEntry`); the binary does the same for stdin and then writes error
 * CSS (`invalid_utf8_on_stdin_fails_like_a_file`). Decoding here, with the
 * shared fatal decoder, is what makes `--stdin` and `--loop` do that too.
 * A `-` job decodes later, inside `compileSlice`, because that is the
 * compile-error path — doing it here would skip the error stylesheet.
 */
function readStdin() {
  const text = decodeUtf8(readStdinBytes());
  if (text === null) throw new Exception("Error: Invalid UTF-8.");
  return text;
}

/**
 * dart's `--source-map-urls`: how the map's `sources[]` reference the inputs.
 * `relative` (dart's default) is the lexical path from the MAP file's directory
 * to each source, as a URL — each segment percent-encoded, `/` kept as the
 * separator; `absolute` is a `file://` URL. A source that is not a `file:` URL
 * (a custom importer's) passes through untouched. Mirrors `adjust_sources` in
 * ../../src/main.rs.
 */
function adjustSources(sources, mapDir, mode, stdinText) {
  return (sources || []).map((src) => {
    // A stdin entry has no path: dart records its text as a data: URI.
    if (src === "stdin" || src === "-") {
      return stdinText === undefined ? src : `data:;charset=utf-8,${uricEncode(stdinText)}`;
    }
    let path;
    try {
      path = fileURLToPath(src);
    } catch {
      return src;
    }
    if (mode === "absolute") return pathToFileURL(path).href;
    return relative(mapDir, path).split(sep).map(encodeUrlSegment).join("/");
  });
}

/**
 * Percent-encode one URL path segment exactly like dart's `Uri`: keep the
 * unreserved set (`A-Za-z0-9-._~`), the sub-delims (`!$&'()*+,;=`) and `@`.
 * `encodeURIComponent` escapes the sub-delims, which would spell a source
 * named `the+me,1.scss` differently from dart.
 */
function encodeUrlSegment(seg) {
  let out = "";
  for (const byte of new TextEncoder().encode(seg)) {
    const c = String.fromCharCode(byte);
    if (/[A-Za-z0-9\-._~!$&'()*+,;=@]/.test(c)) out += c;
    else out += `%${byte.toString(16).toUpperCase().padStart(2, "0")}`;
  }
  return out;
}

/**
 * Percent-encode for a data: URI the way dart's `Uri.dataFromString` does:
 * every byte outside the URI "uric" set becomes uppercase `%XX`. `encodeURI`
 * keeps exactly that set plus `#`, which must be encoded.
 */
function uricEncode(text) {
  return encodeURI(text).replace(/#/g, "%23");
}

/**
 * The map JSON in dart-sass's exact field order:
 * `version, sourceRoot, sources, names, mappings[, file][, sourcesContent]`.
 * `file` is omitted for a map embedded in stdout output, as dart does.
 */
function mapJson(map, sources, file) {
  const out = { version: 3, sourceRoot: "", sources, names: map.names || [], mappings: map.mappings };
  if (file !== undefined) out.file = file;
  if (map.sourcesContent) out.sourcesContent = map.sourcesContent;
  return JSON.stringify(out);
}

/**
 * dart's `sourceMappingURL` footer. The compiled CSS carries no trailing
 * newline, so EXPANDED appends `\n\n/*# … *\/\n` (the line terminator plus
 * dart's blank separator line) and COMPRESSED appends `/*# … *\/\n` with no
 * leading newline. A `*\/` inside the URL is escaped so it cannot end the
 * comment early.
 */
function sourceMapFooter(css, url, style) {
  const safe = url.replace(/\*\//g, "%2A/");
  return style === "compressed"
    ? `${css}/*# sourceMappingURL=${safe} */\n`
    : `${css}\n\n/*# sourceMappingURL=${safe} */\n`;
}

/** dart's inline map URI: percent-encoded JSON, not base64 (`Uri.dataFromString`). */
function dataUri(json) {
  return `data:application/json;charset=utf-8,${uricEncode(json)}`;
}

/**
 * Write a compile result to `outPath` (file) or stdout. The source map is
 * either inlined as a data: URI (`--embed-source-map`) or written as a `.map`
 * sidecar plus a footer. `--no-css` discards everything, output file included.
 */
function emit(result, outPath, wantMap, opts, stdinText) {
  // Writing can fail for reasons the compile cannot see — a destination that
  // is a directory, a read-only tree, a full disk. The native CLI reports
  // `cannot write <path>: …` and moves on to the next job rather than dying
  // mid-batch, so this returns the message instead of throwing.
  const write = (path, data) => {
    try {
      writeFileSync(path, data);
      return undefined;
    } catch (e) {
      return `error: cannot write ${path}: ${e && e.message ? e.message : e}`;
    }
  };
  // --no-css: the compile (and its diagnostics) was all that was wanted — no
  // stdout, no file, and an existing output is left exactly as it was.
  if (opts.noCss) return;
  // A `<dir>:<dir>` job writes into a tree that may not exist yet, and the map
  // goes in before the CSS (dart's order: nothing should point at a map that
  // failed to write), so the directory has to exist before either.
  if (outPath) {
    try {
      mkdirSync(dirname(outPath), { recursive: true });
    } catch (e) {
      return `error: cannot write ${outPath}: ${e && e.message ? e.message : e}`;
    }
  }
  const body = result.css.replace(/\n?$/, "");
  let css;
  if (wantMap && result.sourceMap) {
    // A stdout map can only be embedded, and dart gives it absolute sources
    // and no `file` field; a file's map is adjusted relative to the `.map`,
    // which sits next to the CSS.
    const mode = outPath ? opts.sourceMapUrls || "relative" : "absolute";
    // Lexical on both sides, as `adjust_sources` is natively: the compiler
    // stamps each source as the path it was named by, normalized but with its
    // symlinks intact, so the map mirrors the tree the build actually walked.
    const mapDir = outPath ? resolve(dirname(outPath)) : process.cwd();
    const sources = adjustSources(result.sourceMap.sources, mapDir, mode, stdinText);
    const file = outPath ? encodeUrlSegment(basename(outPath)) : undefined;
    const json = mapJson(result.sourceMap, sources, file);
    if (opts.embedSourceMap || !outPath) {
      css = sourceMapFooter(body, dataUri(json), opts.style);
    } else {
      const mapPath = outPath + ".map";
      css = sourceMapFooter(body, encodeUrlSegment(basename(mapPath)), opts.style);
      const mapError = write(mapPath, json);
      if (mapError) return mapError;
    }
  } else {
    // dart terminates a CSS FILE with exactly one newline, an empty stylesheet
    // included; only stdout gets nothing for empty output.
    css = outPath || body ? `${body}\n` : "";
  }
  if (outPath) return write(outPath, css);
  process.stdout.write(css);
  return undefined;
}

/**
 * A COMPILE failed: replace the output with a stylesheet describing the
 * error, so the page shows what broke instead of the CSS of an earlier
 * build. `--no-error-css` removes the output instead, and `--no-css`
 * means no output-side effects at all.
 *
 * Measured against dart-sass 1.104.1 and the native binary, which agree:
 *
 *   a compile error, default   -> the output becomes error CSS
 *   the same, --no-error-css   -> the output is removed
 *   a file that cannot be READ -> the output is left exactly as it was
 *   --no-css                   -> the output is left exactly as it was
 *
 * The third is the reason `message` is required rather than optional: an
 * unreadable entry is not a compile error, there is no diagnostic to
 * render, and the previous build stays. This CLI used to remove the
 * output for that case too.
 *
 * `opts.errorCss` is THREE-valued, which the first version of this
 * missed. To a file, the default and an explicit `--error-css` both
 * write. To STDOUT they differ — measured:
 *
 *   sass bad.scss                 stdout 0B
 *   sass --error-css bad.scss     stdout 546B
 *   sass --no-error-css bad.scss  stdout 0B
 *
 * so "on by default" and "asked for" are not the same state, and
 * `undefined` is the default rather than `true`.
 */
function reportFailure(outPath, opts, message, mayCreate = true) {
  if (opts.noCss) return undefined;
  if (!outPath) {
    // No file: only an EXPLICIT --error-css puts the stylesheet on
    // stdout. Silent by default, as dart is.
    if (opts.errorCss === true) writeFdSync(1, errorCss(message));
    return undefined;
  }
  try {
    if (opts.errorCss !== false) {
      // A broken symlink is not a destination — see `leadsNowhere`. Only
      // the WRITE is refused: everything else this function and its
      // caller do is still right, and skipping the lot was a bug of its
      // own (the removal below, and the caller's `onDisk = null`).
      if (!mayCreate) return undefined;
      // Same as `emit`: the destination tree may not exist yet, and a
      // FIRST compile that fails is exactly when it does not. dart and
      // the binary both write 547 bytes of error CSS into `dist/css/`
      // that was never there; without this we reported ENOENT and left
      // nothing at all — the one case where the error stylesheet is the
      // only thing the browser would have had.
      mkdirSync(dirname(outPath), { recursive: true });
      writeFileSync(outPath, errorCss(message));
    } else {
      // Unlinks the LINK, not what it points at, so a dangling output is
      // removed here exactly as a real one is. `--no-error-css` means the
      // stale output goes, and a broken link is as stale as it gets.
      rmSync(outPath, { force: true });
    }
    return undefined;
  } catch (e) {
    // Returned rather than printed: this belongs to one job's diagnostics, and
    // the caller decides when that job's block reaches stderr.
    const what = opts.errorCss !== false ? "write" : "remove";
    return `error: cannot ${what} ${outPath}: ${e && e.message ? e.message : e}`;
  }
}

/**
 * The `:` index separating `<input>:<output>`, skipping a leading drive
 * letter's colon.
 *
 * No separator is required after the drive colon. `C:in.scss` is
 * drive-RELATIVE — the current directory on C:, which a process tracks per
 * drive — and dart reads it as one path, not as the pair `C` + `in.scss`.
 * Requiring `[\\/]` here made this the third spelling of one rule: the binary
 * gated it on `cfg!(windows)`, this asked for a separator, dart asks for
 * neither (#172). All three answered differently for `C:in.scss`, `a:b` and
 * `a:b:c`.
 */
function colonIndex(p) {
  return p.indexOf(":", /^[a-zA-Z]:/.test(p) ? 2 : 0);
}
/**
 * The key two paths are compared BY. On Windows the filesystem is
 * case-insensitive and dart lowercases each part, so `Src` and `src` name one
 * path; everywhere else a path is compared as written — again like dart, which
 * case-folds for no other platform, not even on a case-insensitive macOS
 * volume. Lexical either way: no `realpath`, so a symlink is not resolved.
 * (`path_key` in ../../src/main.rs, same rule.)
 */
function pathKey(path) {
  const abs = resolve(path);
  return process.platform === "win32" ? abs.toLowerCase() : abs;
}

/**
 * A path with its symlinks resolved, or its absolute form when it cannot be
 * resolved. Two spellings of one directory answer the same string, which is
 * what the walker's cycle detection needs (the native walker canonicalizes for
 * the same reason). NOT for comparing paths a user named — see `pathKey`.
 */
function realPath(path) {
  try {
    return realpathSync(path);
  } catch {
    return resolve(path);
  }
}

/** Is this path a symlink, whatever it points at? */
function isSymlink(path) {
  try {
    readlinkSync(path);
    return true;
  } catch {
    return false;
  }
}

/**
 * A path's canonical form, or `null` when there is nothing there to resolve.
 *
 * `realPath` above falls back to `resolve()` for a path that does not exist,
 * which is right for the walker and wrong here: two paths that do not exist
 * would then compare equal on their spelling alone, which is the lexical
 * question `pathKey` already answers. Identity through symlinks is only a
 * question about files that ARE there.
 */
function realOrNull(path) {
  try {
    return pathKey(realpathSync(path));
  } catch {
    return null;
  }
}

/**
 * Every compilable stylesheet under `dir`, relative to it: `.scss`, `.sass` and
 * `.css` (exact lowercase suffixes) that are not partials, in sorted order.
 * Symlinked directories are followed — dart does — but each directory is
 * visited once by canonical identity, so a symlink cycle cannot loop or
 * duplicate output. Mirrors `expand_dir` in ../../src/main.rs.
 */
function walkStylesheets(dir) {
  const found = [];
  const seen = new Set([realPath(dir)]);
  const stack = [{ abs: dir, rel: "" }];
  while (stack.length > 0) {
    const { abs, rel } = stack.pop();
    let names;
    try {
      names = readdirSync(abs);
    } catch {
      // Not a usage error: the command line named a real directory and
      // the filesystem would not list it. dart and the binary both
      // answer 66 for an input they cannot read.
      fail(`Error reading ${abs}: Cannot open file.`, EXIT_IO);
    }
    // readdir order is unspecified; sort so that, of two names for the same
    // directory (symlinks), the same one is mirrored every run.
    names.sort();
    for (const name of names) {
      const child = join(abs, name);
      const childRel = rel ? join(rel, name) : name;
      let isDir = false;
      try {
        isDir = statSync(child).isDirectory(); // follows symlinks, unlike Dirent
      } catch {
        continue; // a broken link or a file that vanished
      }
      if (isDir) {
        const id = realPath(child);
        if (!seen.has(id)) {
          seen.add(id);
          stack.push({ abs: child, rel: childRel });
        }
      } else if (!name.startsWith("_") && /\.(scss|sass|css)$/.test(name)) {
        found.push(childRel);
      }
    }
  }
  found.sort();
  return found;
}

/** Expand a `<dir>:<dir>` pair into one job per stylesheet under it. */
function expandDirPair(input, output) {
  const jobs = [];
  const inAbs = pathKey(input);
  const outAbs = pathKey(output);
  // dart skips every source INSIDE the output directory when that directory is
  // nested in the source tree: `.:css` run twice would otherwise mirror `css/`
  // into `css/css/`. Nesting is strict — a destination EQUAL to the source is
  // not nested, so `dir:dir` still compiles every file.
  const nested = outAbs !== inAbs && (outAbs + sep).startsWith(inAbs + sep);
  for (const rel of walkStylesheets(input)) {
    const from = join(input, rel);
    const to = join(output, rel.replace(/\.(scss|sass|css)$/, ".css"));
    if (nested && (pathKey(from) + sep).startsWith(outAbs + sep)) continue;
    // dart also skips a plain CSS file whose destination is itself (`dir:dir`
    // with a `plain.css` inside): it would only be rewritten in place.
    if (pathKey(to) === pathKey(from)) continue;
    jobs.push({ input: from, output: to });
  }
  return jobs;
}

/** Whether `path` is a directory (a missing path is not). */
function isDirectory(path) {
  try {
    return statSync(path).isDirectory();
  } catch {
    return false; // missing input: let the compile report it
  }
}

/**
 * Split one `<source>:<destination>` operand. Both sides must be non-empty and
 * there may be exactly one separator, as the native CLI's `split_pair` (and
 * dart, for the second rule) requires — `in.scss:out:other.css` is a mistake,
 * not a destination named `out:other.css`.
 */
function splitPair(arg) {
  const i = colonIndex(arg);
  if (i < 0) fail(`error: expected <input>:<output>, got "${arg}"`);
  const source = arg.slice(0, i);
  const destination = arg.slice(i + 1);
  if (!source || !destination) fail(`error: expected <source>:<destination>, got "${arg}"`);
  if (colonIndex(destination) >= 0) fail(`error: "${arg}" may only contain one ":".`);
  return { source, destination };
}

/**
 * dart keeps its sources in a path-keyed map, so the same file named twice —
 * two spellings of one path, or a directory pair plus an explicit pair naming
 * a file inside it — compiles ONCE, to the destination named last. (An exact
 * duplicate is rejected earlier, as dart does.)
 */
function coalesceJobs(jobs) {
  const byKey = new Map();
  for (const job of jobs) {
    const key = job.input === "-" ? "-" : pathKey(job.input);
    const seen = byKey.get(key);
    if (seen) seen.output = job.output;
    else byKey.set(key, { ...job });
  }
  return [...byKey.values()];
}

/**
 * Parse positionals into `{input, output}` jobs: the `<in>:<out>` pair form, or
 * the space form (`<input> [output]`, where `-o` names the same output). An
 * input of `-` is standard input, as in dart.
 */
function parseJobs(positionals, output) {
  if (positionals.some((p) => colonIndex(p) >= 0)) {
    const pairs = positionals.map(splitPair);
    // dart: each source appears once (`-` included) …
    const seen = new Set();
    for (const { source } of pairs) {
      if (seen.has(source)) fail(`error: Duplicate source "${source}".`);
      seen.add(source);
    }
    // … and a directory on the left compiles the whole tree, as dart-sass and
    // the native CLI do.
    const jobs = [];
    for (const { source, destination } of pairs) {
      if (isDirectory(source)) jobs.push(...expandDirPair(source, destination));
      else jobs.push({ input: source, output: destination });
    }
    return coalesceJobs(jobs);
  }
  const [input, second] = positionals;
  if (input === undefined) return [];
  const out = output !== undefined ? output : second;
  // dart: a bare directory compiles in place (`sasso dir` is `dir:dir`); with
  // an output it may not be a positional argument.
  if (isDirectory(input)) {
    if (out !== undefined) fail(`error: Directory "${input}" may not be a positional arg.`);
    return expandDirPair(input, input);
  }
  return [{ input, output: out }];
}
/**
 * `--update`: true when `output` is at least as new as `input` AND every
 * stylesheet the compile loaded.
 *
 * `deps` is a compile's `loadedUrls`. Checking the entry alone is what this
 * did first, and it left stale CSS on disk whenever a partial changed —
 * silently, which is worse than a slow build (#133). dart-sass walks the
 * graph; so does this now.
 *
 * The graph is known only AFTER a compile, which looks like the wrong order
 * for a flag whose job is to avoid compiling. It is the right order here:
 * `[measured]` on Lichess's 147 entry points, dart's `--update` takes 1.18s to
 * decide that nothing changed, while sasso compiles the whole tree from
 * scratch in 0.48s. Skipping the compile is worth less than the walk costs,
 * and reimplementing `@use`/`@import` resolution in JS to get the graph early
 * would be a second copy of rules that already exist in the compiler. So the
 * compile always runs and `--update` decides whether to WRITE — which is what
 * keeps an unchanged output's mtime stable, the property downstream watchers
 * actually key on.
 */
/**
 * dart's one-line report for `--update` and `--watch`, the only thing either
 * flag says back to a person who leaves it running:
 *
 *     [2026-09-19 12:58:07] Compiled src/one.scss to out/one.css.
 *
 * Measured against dart-sass 1.104.1 on 2026-09-19 — local time to the
 * minute, on STDOUT, one line per file actually written. A skipped output
 * and a failed compile are both silent, and `--quiet` suppresses it (though
 * NOT `--watch`'s banner, which prints either way). It appears under these
 * two flags only: a plain `sass a.scss:a.css` says nothing, and neither do
 * we.
 *
 * Writing it to stderr, as this CLI's `--watch` used to, breaks both halves
 * of the contract at once: a build script grepping stdout for `Compiled`
 * finds nothing, and one treating stderr as a failure signal sees noise on
 * every success.
 */
function compiledLine(input, output) {
  const d = new Date();
  const p2 = (n) => String(n).padStart(2, "0");
  // To the SECOND, like the binary and like dart's own VM build. `sass` from
  // npm prints only the minute, but that is dart-sass truncating
  // `DateTime.now().toString()` by a fixed seven characters — right for the
  // VM's six microsecond digits, one field too many for dart2js's three
  // (#190). Matching the bug would mean two sasso front ends disagreeing to
  // mirror two dart builds disagreeing.
  const stamp =
    `${d.getFullYear()}-${p2(d.getMonth() + 1)}-${p2(d.getDate())} ` +
    `${p2(d.getHours())}:${p2(d.getMinutes())}:${p2(d.getSeconds())}`;
  return `[${stamp}] Compiled ${input === "-" ? "stdin" : input} to ${output}.\n`;
}

/**
 * The lines in COMMAND-LINE order, like `flushDiagnostics` and for the same
 * reason: jobs finish in whatever order a dozen threads finish them in, and
 * dart reports one line per job in the order the arguments were given. The
 * timestamp is taken when the file is written, not when this runs, so
 * buffering does not move it.
 */
function flushCompiled(compiled, count) {
  for (let i = 0; i < count; i++) {
    const line = compiled.get(i);
    if (line) process.stdout.write(line);
  }
}

function isFresh(output, input, deps) {
  // `-` is STANDARD INPUT, not a file named `-`. Two separate reasons it can
  // never be fresh, and the first one bites in practice: with a real file
  // called `-` in the working directory — which `sass - out.css` does not
  // create but a shell redirect easily can — `statSync("-")` succeeds, an
  // output newer than that unrelated file reports FRESH, and the run keeps
  // stale CSS. Even without one, standard input has no mtime, so there is no
  // honest comparison to make. Same rule as the binary, where the entry's
  // `source_path()` is `None` and `output_is_fresh` returns false.
  if (input === "-") return false;
  try {
    if (!existsSync(output)) return false;
    const out = statSync(output).mtimeMs;
    if (out < statSync(input).mtimeMs) return false;
    for (const u of deps || []) {
      let f;
      try {
        f = fileURLToPath(u);
      } catch {
        // A non-file URL (a virtual importer) has no mtime to compare; it
        // cannot be shown unchanged, so it is not treated as fresh.
        return false;
      }
      try {
        if (out < statSync(f).mtimeMs) return false;
      } catch {
        // A dependency that has vanished since the compile: not fresh.
        return false;
      }
    }
    return true;
  } catch {
    return false;
  }
}

// `--watch`: recompile `input` -> `output` whenever the input or any of its
// dependencies (the compile's `loadedUrls`) changes. Watches the directories of
// all involved files (so editor atomic-saves are caught) and debounces bursts.
function runWatch(input, output, common, opts) {
  if (!output) fail("error: --watch requires an output file (sasso --watch in.scss out.css)");
  // `--poll` is the native watcher OFF, `--no-poll` is the sweep off, and
  // by default both run: see the flag's own comment, and `_poller.mjs` for
  // why one of them cannot be trusted alone.
  const polling = opts.poll !== false;
  const nativeWatch = opts.poll !== true;
  const watchers = makeWatchers({
    watch,
    exists: existsSync,
    onEvent: (d, _event, fn) => onDirEvent(d, fn),
    // A watched directory that has gone waits for its return the same
    // way an absent load path does. Only load paths were probed, so a
    // dependency directory deleted and put back was never watched
    // again — and on Linux the dead handle says nothing at all.
    onMissing: (d) => probes.arm(d),
    report: (line) => writeStderrSync(line + "\n"),
  });
  // What is on disk, so the catch-up writes nothing when nothing
  // changed. The MAP counts too: a whitespace-only edit leaves the CSS
  // identical and moves every mapping, and comparing the CSS alone left
  // the sidecar stale. `null` means "unknown" — see the failure path,
  // which must clear it or fixing a typo back to what it was would find
  // the CSS unchanged and leave the error stylesheet on disk forever.
  let onDisk = null;
  // Did anything in THIS burst actually produce new CSS?
  //
  // A burst is a provisional run plus its catch-up, and the catch-up
  // almost always produces exactly what the provisional already wrote —
  // so "did this run write" is the wrong question to ask when deciding
  // whether to report. "Did this burst write" is the right one.
  //
  // It is also what separates a real save from a second notification of
  // one. On macOS a save reaches the watch twice, once from the sweep and
  // again from an `fs.watch` event seconds later (#164), and the second
  // burst produces nothing new at either step. Comparing the diagnostic
  // TEXT instead cannot tell those apart, because one save's `@warn` is
  // usually the same string as the last one's — tried, and it silenced
  // every save after the first.
  let burstWrote = false;
  // Has this watch ever successfully written the output? Never reset,
  // unlike `onDisk`, which a failure clears.
  //
  // It is what decides whether the error stylesheet may go through a
  // SYMLINKED output. A link we have written through is ours; one we
  // have not could be pointing at anything, and `aliasesASource` cannot
  // always tell — a dependency that EXISTS but fails to load never
  // reaches `known`, because the compile throws before it reports what
  // it loaded. Measured: `out.css -> _v.scss` with `_v.scss` holding
  // invalid UTF-8, and `_v.scss` came back holding the error stylesheet.
  //
  // The span does not help either, which is worth recording: the error
  // that reaches the write is `Undefined variable` in `main.scss`, not
  // the read failure in `_v.scss`.
  let everWrote = false;
  const artifacts = (result) =>
    `${result.css}\u0000${result.sourceMap ? JSON.stringify(result.sourceMap) : ""}`;
  // The last set of files a compile actually loaded, seeded with the entry.
  // Kept across a FAILED compile: a failure has no `loadedUrls`, and the
  // first version of this narrowed the set to the entry alone when one
  // happened. The directory watcher stayed in place, but the filename
  // filter below no longer recognised the dependency, so fixing the file
  // you had just broken did nothing — measured, and dart recovers.
  let known = new Set([pathKey(input)]);
  // While a compile is failing, anything in a watched directory may be the
  // fix: the file you broke, or a file that was missing and has just been
  // created. Filtering by `known` cannot see the second of those.
  let failing = false;
  // Except our own output, which lands in a watched directory and would
  // otherwise retrigger the compile that wrote it, forever.
  // `pathKey`, not `resolve`: it lowercases on Windows, where `SRC/a.scss`
  // and `src/a.scss` are one file. Comparing raw `resolve()` strings meant
  // a differently-cased spelling missed `ours`, and while `failing` the
  // output's own removal could then retrigger the watch.
  const ours = new Set([pathKey(output), `${pathKey(output)}.map`]);
  // Load paths are watched whether or not anything has been loaded from
  // them, because the interesting case is a file that is NOT there yet:
  // `@use "viaload"` fails, `known` holds only the entry, and the file
  // created later in `inc/` is in a directory nobody is watching. Widening
  // the filter cannot help — there is no watcher on that directory at all.
  // dart watches load paths too (measured: it sees this, we did not).
  const loadPathDirs = (common.loadPaths || []).map((d) => resolve(d));
  const aliasesASource = () => {
    const dest = pathKey(output);
    if (dest === pathKey(input) || known.has(dest)) return true;
    // …and through any symlink, because two names for one file is the
    // other way to reach it. `out.css -> main.scss` passes the comparison
    // above and then overwrites the stylesheet with its own CSS.
    //
    // A second opinion rather than the rule: `realpathSync` answers only
    // for a path that EXISTS, and an output that is not there yet cannot
    // alias anything — which is also why the whole thing is skipped when
    // the destination does not resolve, rather than paying a `realpath`
    // per dependency on every compile for nothing.
    //
    // dart has a guard here too and it is racy: measured 2026-09-22, 29
    // runs of `out.css -> main.scss` under `--watch`, dart declined 26
    // times and destroyed the stylesheet 3. The binary took the
    // deterministic side in #166 and this is the same rule.
    const realDest = realOrNull(output);
    // A destination that will not resolve is not this question's to
    // answer. It is a symlink to something that is not there, and what
    // it NAMES cannot always be recognised — when the watch starts with
    // a dependency already missing, the first compile throws before it
    // reports what it loaded, so `known` holds the entry and nothing
    // else. `leadsNowhere` settles that case for every shape at once, by
    // refusing to follow such a link at all on the path that would
    // create the file.
    //
    // An earlier version compared the link's target against `known`
    // here. It worked for one hop and one shape, missed the chain and
    // the startup case, and is dead weight now: removing it changes no
    // test, which is how it was found.
    if (realDest === null) return false;
    // `real !== null` is redundant while the check above stands, and it
    // is here so that moving that check cannot quietly reintroduce the
    // lie it settles. Neither can be made to fail from a test today.
    const same = (f) => {
      const real = realOrNull(f);
      return real !== null && real === realDest;
    };
    return same(input) || [...known].some(same);
  };
  // One per absent load path, keyed so re-arming replaces rather than adds
  // — see `_probe.mjs` for what happened when it did not.
  const probes = makeProbe({
    watch,
    exists: existsSync,
    dirname,
    onAppear: () => schedule(),
  });
  // Snapshots for events that arrive with no filename — and NOTHING else
  // reads them, so they are not taken until such an event is actually
  // seen. macOS and Linux always name their events, so on the platforms
  // most people develop on these stay empty forever.
  //
  // Taking them eagerly cost what a survey of a directory costs, on every
  // compile. Measured against the number of files on a load path:
  //
  //     10 files -> 13.7ms      2000 files -> 22.7ms
  //    500 files -> 16.2ms      5000 files -> 37.6ms
  //
  // which is most of the latency this whole change exists to remove.
  let sawNameless = false;
  let stamps = new Map();
  // And the same for everything else in the watched directories, minus
  // our own output: what tells a user's fix apart from the removal this
  // watch performed itself, when the platform does not say which file
  // moved. Listing is cheap and happens only on nameless events, which
  // macOS and Linux never send.
  let neighbours = new Map();
  const surveyNeighbours = (dirs) => {
    const seen = new Map();
    for (const d of dirs) {
      let names = [];
      try {
        names = readdirSync(d);
      } catch {
        continue; // vanished; the next event will notice
      }
      for (const n of names) {
        const full = pathKey(join(d, n));
        if (ours.has(full)) continue;
        seen.set(full, mtime(full));
      }
    }
    return seen;
  };
  const anythingElseChanged = () => {
    const now = surveyNeighbours(new Set([...[...known].map((f) => dirname(f)), ...loadPathDirs]));
    if (now.size !== neighbours.size) return true;
    for (const [f, m] of now) if (neighbours.get(f) !== m) return true;
    return false;
  };
  const watchedDirs = () => new Set([...[...known].map((f) => dirname(f)), ...loadPathDirs]);
  /**
   * Re-baseline the sweep.
   *
   * `before` is what the filesystem looked like when the compile STARTED,
   * and it wins wherever it has an answer. Stamping after the compile
   * instead adopts a save made while it was running as the baseline, and
   * no later sweep can see that save — measured before this, writing the
   * instant the first output appeared: 7 of 40 saves waited longer than
   * half a second for the native watcher, one of them 7.7s. It is the
   * same rule as the binary's `Snapshot::follow`, which keeps the
   * earliest observation of a path for exactly this reason.
   *
   * A stamp that is older than what the compile actually read costs one
   * extra sweep hit, and that compile produces identical CSS and is not
   * written or narrated. Losing a save costs the save.
   */
  const takeSnapshots = (before) => {
    // A path `before` already knew keeps that reading; one the compile
    // DISCOVERED has only a post-compile mtime, which `baselineFor`
    // refuses to trust if it moved after the compile began.
    stamps = new Map(
      [...known].map((f) => [f, before?.stamps.has(f) ? before.stamps.get(f) : baselineFor(mtime(f), before?.startedAt)]),
    );
    if (!before) {
      neighbours = surveyNeighbours(watchedDirs());
      return;
    }
    // What we knew before the compile, PLUS a fresh look at directories
    // that only came into scope during it. `@use "sub/dep"` brings `sub/`
    // into the watched set on the first compile, and carrying the older
    // survey across unchanged makes every file in it look like an
    // arrival: measured, three compiles where there should be one, on
    // every idle startup.
    //
    // Re-surveying EVERYTHING instead would fix that and break the other
    // half — a file deleted while the compile ran would vanish from the
    // baseline too, and the deletion with it. Only the new directories
    // are re-asked.
    neighbours = new Map(before.neighbours);
    const fresh = new Set([...watchedDirs()].filter((d) => !before.dirs.has(d)));
    // The same rule, because it is the same situation one level up: a
    // directory that only came into scope during the compile is surveyed
    // after it, so anything in there that moved meanwhile would otherwise
    // become its own baseline.
    if (fresh.size) {
      for (const [f, m] of surveyNeighbours(fresh)) neighbours.set(f, baselineFor(m, before.startedAt));
    }
  };
  /** What the sweep would have seen just before a compile started. */
  const snapshotBefore = () => {
    const dirs = watchedDirs();
    // Read before anything else here: a file whose mtime is at or past it
    // moved after this compile began, so what the compile read cannot be
    // assumed to be what is on disk now.
    const startedAt = Date.now();
    return { startedAt, stamps: new Map([...known].map((f) => [f, mtime(f)])), neighbours: surveyNeighbours(dirs), dirs };
  };
  const mtime = (f) => {
    try {
      return statSync(f).mtimeMs;
    } catch {
      return null;
    }
  };

  /** Re-arm the watchers. `loadedUrls` omitted = keep the last known set. */
  const rewatch = (loadedUrls, before) => {
    if (loadedUrls) {
      const files = new Set([pathKey(input)]);
      for (const u of loadedUrls) {
        try {
          files.add(pathKey(fileURLToPath(u)));
        } catch {
          // non-file URL (a virtual importer) — nothing to watch
        }
      }
      known = files;
    }
    if (sawNameless || polling) takeSnapshots(before);
    probes.closeAll();

    // A load path that does not exist YET cannot be watched — `fs.watch`
    // throws and the directory is dropped, so `-I generated` before
    // `generated/` exists means the file created there later produces no
    // event anywhere and the watch never recovers. dart handles this
    // (measured: it compiles, we did not), and its own suite has a case
    // named "on a load path that was created".
    //
    // So watch the nearest ancestor that DOES exist and wait for the
    // directory to appear. If what appears is only the next link in the
    // chain — `-I a/b/c` with only `a` there — the probe re-arms deeper
    // rather than giving up, which is why this is a function and not a
    // single `watch`.
    const dirs = new Set([...[...known].map((f) => dirname(f)), ...loadPathDirs]);
    // `makeProbe` is `fs.watch` underneath, so under `--poll` arming one
    // would be the native watcher coming in through the side door — and
    // with it the latency the flag exists to escape. Measured before this
    // gate: `--poll` picked the created load path up in 516-4064 ms, which
    // is `fs.watch`'s number here, not the sweep's.
    //
    // The sweep covers it without them. An absent load path is already in
    // `watchedDirs()`; `surveyNeighbours` skips it while `readdirSync`
    // throws, and the moment it exists with a file in it the entry set
    // differs.
    if (nativeWatch) {
      for (const lp of loadPathDirs) {
        if (!existsSync(lp)) probes.arm(lp);
      }
    }
    // Close only what is no longer needed and open only what is new,
    // re-arm a watcher that fails, and say so when one cannot be
    // recovered. All of that lives in `_watchers.mjs`, where a fake
    // `watch` can produce the failures this machine will not.
    if (nativeWatch) watchers.sync(dirs);
  };

  /** One event from one watched directory. */
  const onDirEvent = (d, fn) => {
    // The first nameless event cannot be judged — there is no snapshot
    // to compare against, because taking one before ever seeing such an
    // event is what made every compile pay for a directory survey.
    // Compile once, start snapshotting, and every nameless event after
    // this one is answerable.
    if (!fn && !sawNameless) {
      sawNameless = true;
      takeSnapshots();
      schedule();
      return;
    }
    if (
      triggersRecompile({
        path: fn ? pathKey(join(d, fn)) : null,
        known,
        ours,
        failing,
        anyKnownMoved: () => [...known].some((f) => stamps.get(f) !== mtime(f)),
        anythingElseChanged,
      })
    ) {
      schedule();
    }
  };

  /**
   * Compile once and emit. Returns whether it succeeded.
   *
   * `provisional` marks the speculative compile at the head of a burst
   * (see `schedule`): a failure there is not reported and removes
   * nothing, because the likeliest cause is a file still being written
   * rather than anything the user did wrong. The catch-up compile that
   * follows is never provisional, so an error that is real still reaches
   * the terminal — one window later.
   */
  const recompile = (provisional) => {
    // A provisional run is the head of a burst, so it starts a new one.
    if (provisional) burstWrote = false;
    // BEFORE the compile reads a single file — see `takeSnapshots`.
    const before = polling || sawNameless ? snapshotBefore() : undefined;
    try {
      // A provisional run says NOTHING, and its `@warn`s are the half that
      // was missing. Its failures were already silent, for the reason in
      // `_coalesce.mjs`: what it read is not always what the save finally
      // left there. A warning is the same claim about the same bytes, so
      // printing it twice per save is printing it once too often —
      // measured against dart 1.104.1, one `@warn` and three saves:
      //
      //   dart            WARNING x4   (one at startup, one per save)
      //   sasso binary    WARNING x4
      //   npm, before     WARNING x7
      //
      // The binary drops a provisional run's whole output for this; here
      // the errors were already dropped and only the logger was left.
      //
      // An authoritative run's diagnostics are CAPTURED rather than let
      // through: whether they are worth printing is not known until the
      // CSS has been compared with what is already on disk, and by then
      // the engine's logger has long since written them.
      let said = "";
      let result;
      if (provisional) {
        result = compile(input, { ...common, logger: Logger.silent });
      } else {
        const ran = captureStderr(() => compile(input, common));
        said = ran.text;
        if (ran.error) {
          // Whatever it managed to warn about before failing is still the
          // user's to see; the catch below adds the error itself.
          if (said) writeStderrSync(said);
          throw ran.error;
        }
        result = ran.value;
      }
      // Watch before emitting: once the output file is visible, dependency
      // watchers are guaranteed live (a change saved right after the output
      // appears must not fall between emit and watcher registration).
      rewatch(result.loadedUrls, before);
      // Never write over a file this compile READ. `sasso a.scss a.scss`
      // and `sasso main.scss _v.scss` both replace a source with its own
      // CSS — measured, and dart does that too for a one-shot compile, so
      // it is not ours to change there. Under `--watch` dart declines:
      // the transcript is the banner and nothing else, and the source is
      // untouched. We compiled and destroyed it, once at startup and
      // again on every save.
      //
      // Silent, because dart is silent. A watch that overwrites your
      // stylesheet every time you save it is the one outcome worth
      // ruling out even at the cost of saying nothing.
      if (aliasesASource()) {
        if (said) writeStderrSync(said);
        failing = false;
        return true;
      }
      // Every save compiles twice — once at the head of the burst, once
      // to catch up — so most catch-ups produce exactly what is already
      // on disk. Writing it again would touch the output's mtime for
      // nothing, which is the property downstream watchers key on, and
      // print a second `Compiled` line where dart prints one per save.
      const produced = artifacts(result);
      if (onDisk !== null && onDisk === produced) {
        // Nothing new from this run. Report only if the burst it belongs
        // to did produce something — that is the catch-up after a real
        // save, where the provisional already wrote the CSS and this run
        // is the one allowed to speak about it.
        if (!provisional && burstWrote) {
          if (said) writeStderrSync(said);
          if (!opts.noCss && !opts.quiet) process.stdout.write(compiledLine(input, output));
        }
        failing = false;
        return true;
      }
      // Before the `Compiled` line, which is the order dart prints them in.
      if (said) writeStderrSync(said);
      const writeError = emit(result, output, common.sourceMap, opts);
      if (writeError) process.stderr.write(`${writeError}\n`);
      else {
        onDisk = produced;
        burstWrote = true;
        everWrote = true;
        // A provisional run narrates nothing, exactly as the binary's
        // does: its whole stdout is dropped there. The catch-up 50ms
        // behind it says the line instead, which is what puts the
        // WARNING before it — the order dart and the binary both print
        // (measured 2026-09-22, all three engines).
        if (!provisional && !opts.noCss && !opts.quiet) process.stdout.write(compiledLine(input, output));
      }
      failing = false;
    } catch (e) {
      if (provisional) return false;
      const msg = e instanceof Exception ? e.message : `error: ${e && e.message ? e.message : e}`;
      process.stderr.write(msg.replace(/\n?$/, "\n"));
      // Not when the destination is a source. The success path already
      // refuses to WRITE over one; deleting it here would be the same
      // mistake with a worse outcome — and it is only unreachable today
      // because an aliased watch never recompiles, which is one filter
      // change away from being false.
      //
      // …and not THROUGH a broken symlink either, which is a different
      // question and one `aliasesASource` cannot always answer. When the
      // watch starts with a dependency already missing, the first compile
      // throws before it reports what it loaded, so `known` holds the
      // entry and nothing else — and `out.css -> _v.scss` with `_v.scss`
      // absent names a file this watch has never heard of. Measured: the
      // error stylesheet went through the link and CREATED `_v.scss`,
      // holding the error about `_v.scss`.
      //
      // The rule that settles it without guessing: this path may create
      // the OUTPUT, which is what `reportFailure`'s `mkdirSync` is for
      // and what dart does, but it may not follow a link that goes
      // nowhere in order to create something else. The cost is a setup
      // where the output is a symlink to a path that does not exist yet
      // — there the first failing build writes no error stylesheet, and
      // the error still reaches stderr. The success path still creates
      // it, so the setup starts working the moment a build succeeds.
      //
      // It is `mayCreate` and not a skip of this whole branch, because
      // the rest of it is unrelated and both halves mattered: under
      // `--no-error-css` the removal still has to unlink the link, and
      // `onDisk` still has to be forgotten or "fix the typo back to what
      // it was" leaves the output missing forever (#159, measured again
      // here).
      if (!aliasesASource() && e instanceof Exception) {
        const writeError = reportFailure(output, opts, e.message, everWrote || !isSymlink(output));
        if (writeError) process.stderr.write(`${writeError}\n`);
        // The destination is no longer the CSS we last wrote — it is the
        // error stylesheet, or gone. Forgetting that is how "fix the typo
        // back to what it was" left the error on the page forever: the
        // next compile matched the remembered CSS and skipped the write.
        onDisk = null;
      }
      // Keep the set we already had — a failure reports no `loadedUrls`,
      // and throwing away what we knew is what broke recovery — and accept
      // anything in those directories until a compile succeeds again.
      failing = true;
      rewatch(undefined, before);
      return false;
    }
    return true;
  };

  /**
   * Compile on the FIRST event of a burst, not 50 ms after the last one.
   *
   * The window is still 50 ms and still coalesces — it just no longer sits
   * in front of the common case, which is one save with nothing after it.
   * Median edit-to-correct-CSS by `bench/scripts/watch_latency.mjs`,
   * 2026-09-19, all three runs back to back on one machine:
   *
   *              trailing 50   this    dart 1.104.1
   *   atomic          63.7ms  12.4ms    82.4ms
   *   quick           63.6ms  12.4ms    83.7ms
   *   slow           113.4ms  63.0ms   107.5ms
   *
   * The catch is that a leading edge reads the file the instant it moves,
   * and an editor that saves in place can be caught mid-write. Compiling
   * then fails, and the first three attempts at this printed a parse error
   * and deleted the output on EVERY slow save — faster and much worse.
   *
   * So the first compile of a burst is PROVISIONAL: a failure is silent,
   * removes nothing, and forces a catch-up at the end of the window, which
   * is not provisional and reports whatever it finds. A half-written file
   * costs one wasted compile; a real error is reported 50 ms later than it
   * used to be, which nobody can perceive. Zero spurious errors across all
   * three save styles, where the naive leading edge had 15 out of 15.
   */
  const schedule = coalesce({ windowMs: 50, run: recompile });

  // The sweep asks the two questions the event filter already asks, and
  // asks them of the filesystem instead of waiting to be told: did a file
  // we loaded move, and did anything else in a watched directory. Both
  // exclude our own output, or the watch would answer its own write.
  //
  // Re-baselining here rather than leaving it to the compile is what stops
  // one change being reported on every tick from now on: `schedule` may
  // coalesce this into a run that has not happened yet.
  const poller = makePoller({
    sweep: () => {
      const moved = [...known].some((f) => stamps.get(f) !== mtime(f)) || anythingElseChanged();
      if (moved) takeSnapshots();
      return moved;
    },
    onChange: () => schedule(),
  });

  recompile(false);
  // The compile has already baselined the sweep from BEFORE it read
  // anything, which is what makes a save during that first compile
  // visible; re-stamping here would throw exactly that away.
  if (polling) poller.start();
  // dart's wording, and on stdout beside the compile lines. `--quiet`
  // silences those but NOT this: measured 2026-09-19, `sass --quiet --watch`
  // still prints the banner, which is the only sign the process is alive.
  //
  // The trailing blank line is dart's too, and it is once — after the
  // banner, not between later recompiles (measured over three rebuilds).
  process.stdout.write("Sass is watching for changes. Press Ctrl-C to stop.\n\n");
}

/**
 * `--indented` for a FILE input, which forces the indented syntax whatever the
 * extension says — dart-sass documents the flag for stdin but applies it to
 * files too (measured 2026-09-17), and so does the native CLI. Without it the
 * extension decides, so the option is left out entirely.
 */
function syntaxOf(opts) {
  return opts.indented ? { syntax: "indented" } : {};
}

/**
 * Whether this job needs a source map: on by default when writing to a file,
 * off for stdout — and never under `--no-css`, which discards the output, so
 * building a map for it would be paid for and thrown away (the native CLI
 * makes the same call).
 */
function wantSourceMap(opts, output) {
  if (opts.noCss) return false;
  return opts.sourceMap === undefined ? !!output || opts.embedSourceMap : opts.sourceMap;
}

/**
 * `--loop N`: compile the same input N times in-process and report throughput
 * on stderr, then print the last CSS (unless `--no-css`). As in the native CLI
 * an untimed WARM pass runs first — it is the one that reports diagnostics and
 * fails early — and only the timed iterations are silent, so the number
 * measures compiling rather than the first-compile costs around it. No source
 * map is built, and it only ever compiles to stdout.
 */
function runLoop(opts, common) {
  const path = opts.stdin ? undefined : opts.positionals[0];
  // No input at all would otherwise block on a terminal's stdin.
  if (path === undefined && !opts.stdin) {
    fail("error: no input file (pass a path, an <in>:<out> pair, or --stdin)");
  }
  const fromStdin = path === undefined || path === "-";
  // Decoded inside `compileOnce`, not before `run`. Invalid UTF-8 throws the
  // entry's Exception, and `run` is what turns that into the failure line;
  // decoding first would be an uncaught exception and a stack trace.
  let source;
  // A file keeps its own syntax (`.sass`, `.css`) and its own URL, as it would
  // outside the loop; only stdin takes `--indented`.
  const compileOnce = (options) => {
    if (!fromStdin) return compile(path, { ...options, sourceMap: false, ...syntaxOf(opts) });
    source ??= readStdin();
    return compileString(source, { ...options, sourceMap: false, syntax: opts.indented ? "indented" : "scss" });
  };
  const run = (options) => {
    // Same reason as the `--stdin` path: the warm pass is the one that
    // reports, and `fail` exits before an asynchronous stderr write can drain.
    //
    // The TIMED passes carry `Logger.silent`, so nothing of theirs can reach
    // stderr and there is nothing to capture. They skip it: swapping
    // `process.stderr.write` and allocating a chunk list per iteration is this
    // CLI's bookkeeping, and `--loop` exists to report the compiler's time.
    const timed = options.logger === Logger.silent;
    const attempt = timed ? compileOrError(() => compileOnce(options)) : captureStderr(() => compileOnce(options));
    if (attempt.text) writeStderrSync(attempt.text);
    if (!attempt.error) return attempt.value.css;
    const e = attempt.error;
    // The same split the batch path makes, and it already told these
    // three apart for the MESSAGE — it just answered 1 for all of them.
    const msg =
      e instanceof Exception
        ? e.message
        : e && e.code === "ENOENT"
          ? `Error reading ${path}: Cannot open file.`
          : `error: ${e && e.message ? e.message : e}`;
    fail(msg, e instanceof Exception ? EXIT_COMPILE : EXIT_IO);
    return "";
  };

  // The warm/correctness pass: diagnostics once, and a failure here never
  // reaches the timer.
  let last = run(common);
  const silent = { ...common, logger: Logger.silent };
  const start = process.hrtime.bigint();
  for (let i = 0; i < opts.loop; i++) {
    last = run(silent);
  }
  const ms = Number(process.hrtime.bigint() - start) / 1e6;
  const per = ms / opts.loop;
  const perSec = per > 0 ? 1000 / per : Infinity;
  // The native CLI prints a Rust `Duration`, which picks its own unit.
  const elapsed =
    ms >= 1000 ? `${(ms / 1000).toFixed(3)}s` : ms >= 1 ? `${ms.toFixed(3)}ms` : `${(ms * 1000).toFixed(3)}µs`;
  process.stderr.write(
    `sasso: ${opts.loop} compiles in ${elapsed} => ${per.toFixed(3)} ms/compile, ${perSec.toFixed(1)} compiles/sec\n`,
  );
  if (!opts.noCss && last) process.stdout.write(`${last.replace(/\n?$/, "")}\n`);
}

/** A worker thread: same compile loop, same code, pulling from the shared index. */
async function runWorker() {
  const { shared, opts, ctl, stdinBytes } = workerData;
  await loadEngine();
  const common = commonOptions(opts);
  // Only the jobs THIS worker took are in the map; the parent merges by index,
  // so the batch reports in command-line order however the threads interleaved.
  const diagnostics = new Map();
  const compiled = new Map();
  const { failed, worst } = compileSlice(sharedList(shared), opts, common, ctl, stdinBytes, diagnostics, compiled);
  parentPort.postMessage({ failed, worst, diagnostics: [...diagnostics], compiled: [...compiled] });
}

/** The compile options every job shares, rebuilt per thread (a logger cannot be cloned). */
function commonOptions(opts) {
  const common = {
    style: opts.style,
    loadPaths: opts.loadPaths,
    sourceMapIncludeSources: opts.embedSources,
    charset: opts.charset,
    // --no-unicode is not a no-op: it selects the ASCII glyph set for every
    // diagnostic the compiler renders (`,`/`|`/`'` for `╷`/`│`/`╵`).
    unicode: opts.unicode,
    // The COMPILER applies --quiet-deps, from how each file was resolved: the
    // only place that knows, and early enough that a silenced warning does not
    // count toward the deprecation repetition cap either. Filtering here by
    // where a file lives would silence the wrong ones and lose the formatted
    // diagnostic for the rest.
    quietDeps: opts.quietDeps,
    // Also the compiler's job, and for the same reason: filtered out here it
    // would silence the warnings but still tally them, and the run would end
    // with "N repetitive deprecation warnings omitted" counting exactly the
    // ones the caller silenced.
    silenceDeprecations: opts.silenceDeprecations,
  };
  if (opts.quiet) common.logger = Logger.silent;
  return common;
}

async function main() {
  // Arguments FIRST: `--help` and `--version` answer from this file alone and
  // exit inside `parseArgs`. Loading the engine before them made a metadata
  // question depend on a compiler — `SASSO_ENGINE=native sasso --version` on a
  // machine without the addon printed the addon error instead of the version.
  const opts = parseArgs(process.argv.slice(2));
  // Before the engine, because the fastest engine here is not one: a
  // version-matched release binary on PATH gets the whole command line and
  // this process ends with its exit code. See `pickBinary`.
  // `--engine` REPORTS the hand-off instead of taking it: the question it asks is
  // what THIS install does, and delegating would answer with the binary's own
  // idea of `--engine`, which it does not have at all.
  const binary = pickBinary(opts);
  if (binary && !opts.printEngine) delegate(binary);
  await loadEngine();
  // `--engine` is the answer to "which one did I get?", so it reports and stops
  // — before the "no input file" check, since it needs no input.
  if (opts.printEngine) {
    process.stdout.write(engineReport());
    return;
  }
  // Once, here: workers load their own engine and would each repeat this.
  warnIfFellBack(opts);
  const common = commonOptions(opts);

  // --loop: recompile in-process and report throughput, never writing a file.
  if (opts.loop !== undefined) {
    runLoop(opts, common);
    return;
  }

  // --stdin: a single job reading source from standard input.
  if (opts.stdin) {
    if (opts.watch) fail("error: --watch cannot be used with --stdin");
    const output = opts.output !== undefined ? opts.output : opts.positionals[0];
    const wantMap = wantSourceMap(opts, output);
    // Read inside the capture, same reason as `--loop`: invalid UTF-8 throws
    // the entry Exception, and the handler below is what writes error CSS
    // and exits with that message. A read out here would skip both.
    let source;
    // Captured and written synchronously, like a job's: the engine's logger
    // writes warnings through the ASYNCHRONOUS stream, and `fail` exits at
    // once, so on a pipe a warning would arrive after the error it preceded —
    // or, past the 64 KB pipe buffer, not at all (measured 2026-09-17: a
    // 1.2 MB warning came out of `--stdin` as 65584 bytes through a pipe and
    // 1200070 to a file).
    const run = captureStderr(() => {
      source = readStdin();
      return compileString(source, { ...common, sourceMap: wantMap, syntax: opts.indented ? "indented" : "scss" });
    });
    if (run.text) writeStderrSync(run.text);
    let result;
    try {
      if (run.error) throw run.error;
      result = run.value;
    } catch (e) {
      if (e instanceof Exception) {
        const writeError = reportFailure(output, opts, e.message);
        if (writeError) writeStderrSync(`${writeError}\n`);
      // A failed error-CSS WRITE upgrades this to an I/O failure: the
      // output could not be produced, and dart answers 66 for that
      // (measured 2026-09-23, `bad.scss:adir` -> dart 66, binary 66).
      //
      // A failed REMOVAL under `--no-error-css` does NOT. There was no
      // output to produce, and the cleanup failing does not change what
      // went wrong with the stylesheet — dart stays at 65 there, and
      // says nothing about the removal at all. The binary upgrades and
      // is wrong about it; #182.
        fail(e.message, writeError && opts.errorCss !== false ? EXIT_IO : EXIT_COMPILE);
      }
      // Not a compile error — an unreadable file, say. dart leaves the
      // previous output exactly as it was, and answers 66.
      fail(`error: ${e && e.message ? e.message : e}`, EXIT_IO);
    }
    const writeError = emit(result, output, wantMap, opts, source);
    if (writeError) fail(writeError, EXIT_IO);
    return;
  }

  const jobs = parseJobs(opts.positionals, opts.output);
  if (jobs.length === 0) {
    // A directory pair that expands to nothing (an empty tree, or one holding
    // only partials) is not an error — dart exits 0. Having no input at all is.
    if (opts.positionals.length === 0) {
      fail("error: no input file (pass a path, an <in>:<out> pair, or --stdin)");
    }
    return;
  }

  // dart's second `--update` usage error, alongside the `--stdin` one above:
  // `--update is not allowed when printing to stdout.`, measured 2026-09-19.
  // With no destination there is no mtime to compare, so the flag would do
  // nothing at all. `parseJobs` only produces an output-less job from a lone
  // positional, which is exactly that case; `-o` and a bare directory both
  // come back with an output and are allowed, as they are in the binary.
  if (opts.update && jobs.some((j) => j.output === undefined)) {
    fail("error: --update is not allowed when printing to stdout.");
  }

  if (opts.watch) {
    if (jobs.length !== 1 || !jobs[0].output) fail("error: --watch requires <input> <output>");
    const wantMap = opts.noCss ? false : opts.sourceMap === undefined ? true : opts.sourceMap;
    runWatch(jobs[0].input, jobs[0].output, { ...common, sourceMap: wantMap, ...syntaxOf(opts) }, opts);
    return; // keep the process alive on the watchers
  }

  const { failed, worst } = await runJobs(jobs, opts, common);
  // `process.exit` here would discard whatever of the diagnostics just flushed
  // has not reached the kernel yet — stderr on a PIPE is asynchronous, and a
  // 400-job batch lost 26 of its warnings that way (measured 2026-09-17).
  // Setting the code and returning lets Node finish the writes and exit on its
  // own; nothing else is keeping the loop alive by this point.
  // The cause, not just the fact — 65 for a stylesheet that is wrong, 66
  // for something that could not be read or written, and the worse of the
  // two when a batch has both. `worst` is 0 when nothing failed, so the
  // assignment is safe either way; the `failed` check keeps it obvious.
  if (failed > 0) process.exitCode = worst || EXIT_COMPILE;
}

/**
 * Compile `jobs`, in this thread or across worker threads.
 *
 * The jobs are independent — each reads one input and writes one output — so
 * both CLIs give them one worker per physical core where the topology is
 * known, and one per CPU where it is not — off Linux, and on a Linux that
 * publishes none (see `_jobs.mjs`, and `default_jobs` in `src/main.rs`, which
 * agree on the rule and on why it is not simply the CPU count). Either way it
 * is one worker per job slot, which is what `-j/--jobs` has always claimed.
 * Sequentially, the difference is most of the gap between the two: the 138
 * lila stylesheets that build without npm dependencies take 704 ms through the
 * binary at `-j 1` and 138 ms at its default (measured 2026-09-17, the same
 * corpus and flags as the changelog's table).
 *
 * Workers pull from a SHARED index rather than taking a fixed slice, so one
 * heavy stylesheet cannot leave eleven threads idle. `--stop-on-error` is a
 * second shared cell: whoever fails sets it, and the others stop taking work,
 * which is the native "don't start more files once one fails".
 *
 * Staying in-process is the right answer for one job (a worker costs more than
 * the compile), when `-j 1` asks for it, and when the batch's writes overlap
 * its own paths — dart's last-one-wins, and its write-then-read, are ORDERS,
 * and an order needs a sequence.
 */
async function runJobs(jobs, opts, common) {
  const wanted = opts.jobs ?? defaultJobs();
  // Standard input is read ONCE, here, and handed to whoever needs it — as
  // SHARED bytes, because `workerData` copies what it carries and only the one
  // worker that claims the `-` job ever reads them. (It used to force the whole
  // batch into this thread instead, so one `-` job cost every OTHER job its
  // parallelism.)
  // Raw bytes, not text. Decoding here would turn invalid UTF-8 into an
  // exception before the `-` job exists, and the error stylesheet is written
  // by that job's failure path. `compileSlice` decodes, fatally.
  const stdinBytes = jobs.some((j) => j.input === "-") ? shareBytes(readStdinBytes()) : undefined;

  // Two sources writing to ONE destination have to stay in command-line order:
  // dart compiles both and the LAST one wins — the same file every run
  // (measured against 1.104.1 on 2026-09-17, in both orders). Run them in
  // parallel and the winner is whoever finishes last, which is the race the
  // native CLI has today. A collision is almost always a slip in the command
  // line, so the parallelism given up here costs nothing real.
  //
  // A job writes its CSS *and*, with source maps on, a `<output>.map` beside
  // it — so `a.scss:out.css` and `b.scss:out.css.map` collide on that sidecar
  // even though their `output`s differ. Both count.
  // The same goes for a path one job WRITES and another READS:
  // `a.scss:b.scss b.scss:out.css` compiles a into b.scss and then b.scss into
  // out.css, and dart, being sequential, always reads the new b.scss. In the
  // pool the second job reads whichever version it finds (measured: dart and
  // `-j 1` compile a's output, the pool compiled the original b.scss).
  //
  // `--no-css` is the exception to both: `emit` and `discardStaleOutput`
  // return early under it, so the batch touches no output at all and there is
  // no last-writer to get right.
  //
  // Only ENTRY paths are compared. A job that writes a file some other job
  // `@use`s is the same hazard and cannot be seen from here — the dependency
  // is known only once that stylesheet has been parsed — so it stays a
  // scheduling race, as it is in the native CLI (#87).
  // A job writing over its OWN input is not one of them: `a.scss:a.scss` reads
  // before it writes, inside a single job, so there is no order between
  // threads to get wrong. Only ANOTHER job's input counts, which is why this
  // remembers who owns each one instead of just that it exists.
  const inputOwner = new Map();
  if (!opts.noCss) {
    jobs.forEach((job, i) => {
      if (job.input === "-") return;
      const key = pathKey(job.input);
      if (!inputOwner.has(key)) inputOwner.set(key, i);
    });
  }
  // A path does not have to match exactly to conflict: `a.scss:out` writes the
  // FILE `out` while `b.scss:out/sub.css` needs `out` to be a DIRECTORY, and
  // on a fresh tree whichever job runs first decides which one fails. dart
  // writes the file and then fails the nested job, the same way every run;
  // the pool alternated (measured 2026-09-17: four runs left a directory, two
  // left a file). So an output that is an ancestor or a descendant of another
  // output counts too.
  //
  // Both directions, without comparing every pair: `seenOut` holds the paths
  // written so far and `seenAncestors` every directory above them. A new path
  // conflicts if it IS one already written, if it is a directory some earlier
  // output sits under, or if any directory above it was written as a file.
  // Sharing a parent directory is not a conflict — that is every ordinary
  // batch — because only written paths ever go into `seenOut`.
  const seenOut = new Set();
  const seenAncestors = new Set();
  let collides = false;
  const scan = opts.noCss ? [] : jobs;
  for (let i = 0; i < scan.length && !collides; i++) {
    const job = scan[i];
    if (job.output === undefined) continue;
    const written = [job.output];
    if (wantSourceMap(opts, job.output) && !opts.embedSourceMap) written.push(`${job.output}.map`);
    for (const path of written) {
      const key = pathKey(path);
      const owner = inputOwner.get(key);
      if (seenOut.has(key) || seenAncestors.has(key) || (owner !== undefined && owner !== i)) {
        collides = true;
        break;
      }
      for (const dir of ancestorsOf(key)) {
        if (seenOut.has(dir)) {
          collides = true;
          break;
        }
        // Already recorded means everything above it was too, and was checked
        // against `seenOut` then. A later output that IS one of those
        // directories is still caught, by the `seenAncestors` test above. So
        // the walk can stop here, which is what keeps a directory build from
        // paying for its whole depth once per file.
        if (seenAncestors.has(dir)) break;
        seenAncestors.add(dir);
      }
      if (collides) break;
      seenOut.add(key);
    }
  }

  const workers = Math.min(jobs.length, Math.max(1, wanted));
  // Diagnostics are collected per job and printed in COMMAND-LINE order, never
  // in completion order: the native CLI reports each unit in input order, and
  // two stylesheets' warnings interleaving mid-block would be worse here than
  // there, with a dozen threads writing at once. Sparse — most jobs say
  // nothing, and a directory build can have thousands.
  const diagnostics = new Map();
  // `--update`'s one-line report per written file, collected the same way and
  // for the same reason. Separate from `diagnostics` because it is a
  // different stream: these go to stdout, diagnostics to stderr.
  const compiled = new Map();

  if (workers < 2 || collides) {
    const { failed, worst } = compileSlice(listOf(jobs), opts, common, null, stdinBytes, diagnostics, compiled);
    flushDiagnostics(diagnostics, jobs.length);
    flushCompiled(compiled, jobs.length);
    return { failed, worst };
  }

  // [0] the next job to take, [1] the stop-on-error flag.
  const ctl = new Int32Array(new SharedArrayBuffer(8));
  // The job list goes over SHARED memory, decoded one job at a time as each is
  // claimed. In `workerData` it was structure-cloned per worker instead, which
  // is O(workers x jobs): a 5,000-file directory build at -j 12 paid ~109 MB
  // for twelve copies of a list that never changes (measured 2026-09-17).
  // `positionals` is dropped for the same reason — it is the same paths again,
  // and a worker has no use for them.
  const shared = shareJobs(jobs);
  const { positionals: _unused, ...workerOpts } = opts;
  const results = await Promise.all(
    Array.from({ length: workers }, () => {
      const worker = new Worker(fileURLToPath(import.meta.url), {
        workerData: { sassoWorker: true, shared, opts: workerOpts, ctl, stdinBytes },
        // stdout/stderr are NOT captured here: a job's diagnostics are
        // collected around the compile itself (see `captureStderr`) and come
        // back in the message, while anything else a worker prints — a crash,
        // say — should reach the user rather than a stream nobody reads.
      });
      return new Promise((resolve, reject) => {
        worker.on("message", resolve);
        worker.on("error", reject);
        worker.on("exit", (code) =>
          code === 0
            ? resolve({ failed: 0, worst: 0, diagnostics: [], compiled: [] })
            : resolve({ failed: 1, worst: EXIT_IO, diagnostics: [], compiled: [] }),
        );
      });
    }),
  );
  let failed = 0;
  let worst = 0;
  for (const result of results) {
    failed += result?.failed ?? 0;
    worst = Math.max(worst, result?.worst ?? 0);
    for (const [i, text] of result?.diagnostics ?? []) diagnostics.set(i, text);
    for (const [i, line] of result?.compiled ?? []) compiled.set(i, line);
  }
  flushDiagnostics(diagnostics, jobs.length);
  flushCompiled(compiled, jobs.length);
  return { failed, worst };
}

/** Bytes in shared memory, so `workerData` carries a handle, not a copy. */
function shareBytes(bytes) {
  const shared = new Uint8Array(new SharedArrayBuffer(bytes.length));
  shared.set(bytes);
  return shared;
}

/**
 * The job list as bytes in SHARED memory: every worker reads the same buffer
 * and decodes only the jobs it claims, so the list costs one copy rather than
 * one per thread. `index` holds three ints per job — where its input starts,
 * how long the input is, and how long the output is (-1 for "no output", which
 * is stdout; an empty output is not a thing `parseJobs` produces).
 */
function shareJobs(jobs) {
  const encoder = new TextEncoder();
  const encoded = jobs.map((job) => [
    encoder.encode(job.input),
    job.output === undefined ? undefined : encoder.encode(job.output),
  ]);
  let total = 0;
  for (const [input, output] of encoded) total += input.length + (output ? output.length : 0);
  const bytes = new Uint8Array(new SharedArrayBuffer(total));
  const index = new Int32Array(new SharedArrayBuffer(jobs.length * 12));
  let at = 0;
  encoded.forEach(([input, output], i) => {
    index[i * 3] = at;
    index[i * 3 + 1] = input.length;
    index[i * 3 + 2] = output ? output.length : -1;
    bytes.set(input, at);
    at += input.length;
    if (output) {
      bytes.set(output, at);
      at += output.length;
    }
  });
  return { bytes, index, count: jobs.length };
}

/**
 * Every directory above an absolute path, nearest first, stopping at the root.
 * Used to compare outputs that are not equal but cannot both exist — a file
 * and a directory of the same name.
 */
function* ancestorsOf(key) {
  let at = dirname(key);
  while (at !== dirname(at)) {
    yield at;
    at = dirname(at);
  }
}

/** A `{ length, at(i) }` view over the plain array, for the in-process path. */
function listOf(jobs) {
  return { length: jobs.length, at: (i) => jobs[i] };
}

/** The same view over `shareJobs`'s buffers, decoding a job only when claimed. */
function sharedList(shared) {
  const decoder = new TextDecoder();
  return {
    length: shared.count,
    at(i) {
      const start = shared.index[i * 3];
      const inputLen = shared.index[i * 3 + 1];
      const outputLen = shared.index[i * 3 + 2];
      return {
        input: decoder.decode(shared.bytes.subarray(start, start + inputLen)),
        output:
          outputLen < 0
            ? undefined
            : decoder.decode(shared.bytes.subarray(start + inputLen, start + inputLen + outputLen)),
      };
    },
  };
}

/**
 * Write the collected diagnostics in JOB order, one blank line between one
 * job's block and the next — dart's shape: a warning block already ends in
 * one, an error does not.
 */
function flushDiagnostics(diagnostics, count) {
  let endsBlank = true;
  for (let i = 0; i < count; i++) {
    const text = diagnostics.get(i);
    if (!text) continue;
    if (!endsBlank) process.stderr.write("\n");
    process.stderr.write(text);
    endsBlank = text.endsWith("\n\n");
  }
}

/** `captureStderr`'s shape without the capture, for a pass that cannot report. */
function compileOrError(fn) {
  try {
    return { value: fn() };
  } catch (e) {
    return { error: e };
  }
}

/**
 * Run `fn` with everything it writes to stderr collected instead of printed.
 *
 * The compiler's warnings come from the engine's default logger, which writes
 * the FORMATTED block — location, deprecation label, source snippet — straight
 * to stderr. A `logger` callback would see the message and the span but not
 * that block, so the write is intercepted rather than the logging. A compile
 * is synchronous and a worker runs one at a time, so nothing else of ours can
 * write in between.
 */
function captureStderr(fn) {
  const chunks = [];
  const original = process.stderr.write;
  process.stderr.write = (chunk, encoding, callback) => {
    chunks.push(typeof chunk === "string" ? chunk : Buffer.from(chunk).toString("utf8"));
    if (typeof encoding === "function") encoding();
    else if (typeof callback === "function") callback();
    return true;
  };
  try {
    return { value: fn(), text: chunks.join("") };
  } catch (e) {
    return { error: e, text: chunks.join("") };
  } finally {
    process.stderr.write = original;
  }
}

/**
 * The compile loop itself. With `ctl` it takes jobs from the shared index
 * (worker mode); without it, it walks the list in order (in-process mode).
 * `jobs` is a `{ length, at(i) }` view — a plain array in this thread, shared
 * bytes in a worker. Diagnostics go into the `diagnostics` map under the job's
 * index, not to stderr, so the caller can put them back in job order.
 * Returns `{ failed, worst }` — how many failed, and the most severe cause
 * as an exit code. It never exits the process, so a worker can report back
 * and the parent can decide.
 *
 * `worst` is a plain numeric maximum, and that is not a coincidence: the
 * severity order the binary spells out in `worse()` — I/O beats compile
 * beats ok — is the order of 66, 65, 0. Measured against dart, a batch
 * with one compile error and one unwritable output answers 66 in either
 * command-line order, so it is severity and not recency that decides.
 */
function compileSlice(jobs, opts, common, ctl, stdinBytes, diagnostics, compiled) {
  const note = (i, text) => diagnostics.set(i, (diagnostics.get(i) ?? "") + text);
  // Decoded on first use, so a worker that never claims the `-` job never
  // touches the bytes; there is at most one such job, so at most one decode.
  // Fatal, not `new TextDecoder().decode`: the default decoder substitutes
  // U+FFFD, and a `-` entry would compile bytes a file entry refuses. The
  // throw is the compile error — `captureStderr` is wrapped around this —
  // so the job reports `Error: Invalid UTF-8.` and writes error CSS.
  let stdinText;
  const stdinSource = () => {
    if (stdinText !== undefined) return stdinText;
    if (!stdinBytes) {
      stdinText = "";
      return stdinText;
    }
    // Copy off the SharedArrayBuffer. `TextDecoder` rejects a shared view
    // ("The provided ArrayBufferView value must not be shared"), which would
    // surface as an I/O-shaped error instead of the entry's UTF-8 failure.
    const text = decodeUtf8(Uint8Array.from(stdinBytes));
    if (text === null) throw new Exception("Error: Invalid UTF-8.");
    stdinText = text;
    return stdinText;
  };
  let failed = 0;
  let worst = 0;
  let next = 0;
  for (;;) {
    let i;
    if (ctl) {
      if (Atomics.load(ctl, 1)) break; // another job failed and --stop-on-error is on
      i = Atomics.add(ctl, 0, 1);
      // Re-check AFTER claiming: between the check above and this claim
      // another worker can fail, and starting this job then would be exactly
      // what --stop-on-error forbids. (The native scheduler re-checks in the
      // same place, after its own `next.fetch_add` in ../../src/main.rs.)
      if (Atomics.load(ctl, 1)) break;
    } else {
      i = next++;
    }
    if (i >= jobs.length) break;
    const { input, output } = jobs.at(i);
    const wantMap = wantSourceMap(opts, output);
    // Warnings and deprecations belong to THIS job, wherever it ran.
    const run = captureStderr(() =>
      input === "-"
        ? compileString(stdinSource(), {
            ...common,
            sourceMap: wantMap,
            syntax: opts.indented ? "indented" : "scss",
          })
        : compile(input, { ...common, sourceMap: wantMap, ...syntaxOf(opts) }),
    );
    if (run.text) note(i, run.text);
    let result;
    try {
      if (run.error) throw run.error;
      result = run.value;
    } catch (e) {
      // With several jobs dart keeps going unless --stop-on-error, and exits
      // non-zero at the end.
      const msg =
        e instanceof Exception
          ? e.message
          : e && e.code === "ENOENT"
            ? `Error reading ${input}: Cannot open file.`
            : `error: ${e && e.message ? e.message : e}`;
      // An output-less job with `--error-css` is about to put the
      // stylesheet on stdout, which under `2>&1` is the pipe the
      // warnings are on. The success path above already flushes for
      // this reason; the failure path did not, so a warning the compile
      // had ALREADY printed came out behind the stylesheet.
      //
      // Only the warnings, though. Measured against dart-sass 1.104.1,
      // one file that warns and then fails, merged with `2>&1`:
      //
      //   dart    warn -> css -> error
      //   npm     css -> warn -> error   (before this)
      //   binary  warn -> error -> css   (#160)
      //
      // Flushing the whole block here — the warnings AND the error —
      // would give the binary's order, moving this CLI away from the
      // one front end that agrees with dart. So flush what the compile
      // already said, and let the error follow the stylesheet.
      if (output === undefined && opts.errorCss === true) {
        const said = diagnostics.get(i);
        if (said) {
          writeStderrSync(said);
          diagnostics.delete(i);
        }
      }
      note(i, String(msg).replace(/\n?$/, "\n"));
      failed++;
      // A Sass `Exception` is the stylesheet being wrong; anything else
      // reaching here is the entry not being readable, which is 66 —
      // `Error reading …: Cannot open file.` on the binary.
      worst = Math.max(worst, e instanceof Exception ? EXIT_COMPILE : EXIT_IO);
      // Only a COMPILE error touches the output; an unreadable entry
      // leaves the previous build in place, as dart does.
      if (e instanceof Exception) {
        const writeError = reportFailure(output, opts, e.message);
        if (writeError) note(i, `${writeError}\n`);
      // A failed error-CSS WRITE upgrades this to an I/O failure: the
      // output could not be produced, and dart answers 66 for that
      // (measured 2026-09-23, `bad.scss:adir` -> dart 66, binary 66).
      //
      // A failed REMOVAL under `--no-error-css` does NOT. There was no
      // output to produce, and the cleanup failing does not change what
      // went wrong with the stylesheet — dart stays at 65 there, and
      // says nothing about the removal at all. The binary upgrades and
      // is wrong about it; #182.
        if (writeError && opts.errorCss !== false) worst = Math.max(worst, EXIT_IO);
      }
      if (opts.stopOnError || jobs.length === 1) {
        if (ctl) Atomics.store(ctl, 1, 1);
        break;
      }
      continue;
    }
    // A job with no output file writes its CSS to the terminal the diagnostics
    // are already on, so buffering reverses what the user sees: dart, the
    // native binary and this CLI before the pool all print the warning during
    // the compile, ahead of the CSS. Flush this job's block before `emit`
    // rather than after it. (`parseJobs` only makes an output-less job from a
    // lone positional, so such a job is always the whole batch — there is no
    // other job's block it could jump ahead of.)
    if (output === undefined) {
      const pending = diagnostics.get(i);
      if (pending) {
        // Synchronously, like the `--stdin` and `--loop` paths: `emit` is about
        // to write the CSS to stdout, and under `2>&1` that is the SAME pipe
        // reached through a second stream. Two asynchronous streams on one
        // file descriptor have no defined interleaving, so flushing before
        // `emit` is only an order if this write has actually finished.
        writeStderrSync(pending);
        diagnostics.delete(i);
      }
    }
    // --update: the compile has run, so its `loadedUrls` is what says whether
    // the output on disk is still current. Leave it alone if it is — including
    // its mtime, which is the point.
    if (opts.update && output && isFresh(output, input, result.loadedUrls)) continue;
    const writeError = emit(result, output, wantMap, opts, input === "-" ? stdinSource() : undefined);
    // `!opts.noCss` because `emit` returns undefined immediately under
    // it — no file is written, so there is nothing to announce, and
    // without this the line claimed a write that never happened. The
    // binary was already right here; this CLI was not.
    if (!writeError && opts.update && output && !opts.quiet && !opts.noCss) {
      compiled.set(i, compiledLine(input, output));
    }
    if (writeError) {
      note(i, `${writeError}\n`);
      failed++;
      worst = Math.max(worst, EXIT_IO);
      if (opts.stopOnError) {
        if (ctl) Atomics.store(ctl, 1, 1);
        break;
      }
    }
  }
  return { failed, worst };
}

// A worker thread runs the same file, telling itself apart by its workerData.
if (!isMainThread && workerData && workerData.sassoWorker) runWorker();
else main();
