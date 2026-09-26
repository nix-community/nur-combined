// watch_latency.mjs — how long `--watch` takes to turn a save into correct
// CSS, and how often it says something wrong on the way.
//
//   node bench/scripts/watch_latency.mjs <cmd> [args...]
//   node bench/scripts/watch_latency.mjs node wasm/npm/cli.mjs
//   node bench/scripts/watch_latency.mjs scratch/dart-sass/sass
//
// Latency alone is the wrong number, and measuring it alone is how the
// first attempt at this reached the wrong conclusion. An editor saves in
// more than one way:
//
//   atomic     write a temp file, rename over the target. A reader sees
//              the old bytes or the new ones, never half.
//   quick      truncate and write in one go. A reader can catch it empty,
//              but the window is microseconds.
//   slow       truncate, write, pause, finish. A large file, a network
//              filesystem, a formatter that streams. The window is real.
//
// A watcher that compiles the instant the first event arrives is fastest
// on `atomic` and worst on `slow`: it reads a half-written file, reports a
// parse error, deletes the output, and then has to compile AGAIN when the
// write finishes. So this reports errors alongside milliseconds, and a row
// with a nonzero error count is not a faster row.
import { spawn } from "node:child_process";
import {
  closeSync,
  existsSync,
  ftruncateSync,
  mkdtempSync,
  openSync,
  readFileSync,
  renameSync,
  rmSync,
  writeFileSync,
  writeSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

const given = process.argv.slice(2);
if (given.length === 0) {
  console.error("usage: node bench/scripts/watch_latency.mjs <cmd> [args...]");
  process.exit(64);
}

// Each measurement runs in a fresh temp directory, so the child's cwd is
// NOT the one the harness was invoked from — and `node wasm/npm/cli.mjs`,
// the invocation this file's own usage line recommends, then looks for
// `<temp>/wasm/npm/cli.mjs` and dies before the first sample. (Shipped
// exactly that way, because every run during development passed absolute
// paths.) Anything that names a real file here is pinned to an absolute
// path now; `node`, `sass` and bare flags are left for the PATH lookup.
const [cmd, ...pre] = given.map((a) => {
  try {
    return existsSync(a) ? resolve(a) : a;
  } catch {
    return a;
  }
});

const ITERATIONS = Number(process.env.WATCH_BENCH_ITERATIONS ?? 15);
const SLOW_GAP_MS = Number(process.env.WATCH_BENCH_SLOW_GAP ?? 25);

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const WRITERS = {
  atomic(path, text) {
    const tmp = `${path}.tmp`;
    writeFileSync(tmp, text);
    renameSync(tmp, path);
  },
  quick(path, text) {
    writeFileSync(path, text);
  },
  slow(path, text) {
    const fd = openSync(path, "r+");
    try {
      ftruncateSync(fd, 0);
      const half = Math.floor(text.length / 2);
      writeSync(fd, text.slice(0, half), 0);
      // A busy wait, not a timer: the gap a real editor leaves is the
      // filesystem, and a timer would let this process' event loop run.
      const until = Date.now() + SLOW_GAP_MS;
      while (Date.now() < until) {
        /* spin */
      }
      writeSync(fd, text.slice(half), half);
    } finally {
      closeSync(fd);
    }
  },
};

async function measure(style) {
  const dir = mkdtempSync(join(tmpdir(), "sasso-watchbench-"));
  const dep = join(dir, "_v.scss");
  const out = join(dir, "out.css");
  writeFileSync(join(dir, "main.scss"), '@use "v";\n.a { color: v.$c; }\n');
  writeFileSync(dep, "$c: #000000;\n");

  const proc = spawn(cmd, [...pre, "--no-source-map", "--watch", "main.scss", "out.css"], {
    cwd: dir,
    stdio: ["ignore", "pipe", "pipe"],
  });
  let log = "";
  let died = null;
  proc.stdout.on("data", (b) => (log += b));
  proc.stderr.on("data", (b) => (log += b));
  proc.on("error", (e) => (died = `could not start: ${e.message}`));
  proc.on("exit", (code, signal) => {
    // A watch that exits on its own has failed, whatever its code — it is
    // supposed to sit there until killed.
    if (!killed) died = `exited early (code ${code}, signal ${signal})`;
  });
  let killed = false;

  const css = () => {
    try {
      return readFileSync(out, "utf8");
    } catch {
      return "";
    }
  };

  const samples = [];
  let errored = 0;
  const fail = (why) => {
    const tail = log.trim().split("\n").slice(-12).join("\n    ");
    console.error(`\nwatch_latency: ${style}: ${why}`);
    console.error(`  command: ${[cmd, ...pre].join(" ")}`);
    if (tail) console.error(`  the engine said:\n    ${tail}`);
    process.exitCode = 1;
    throw new Error(why);
  };

  try {
    let ready = false;
    for (let i = 0; i < 400 && !ready; i++) {
      if (died) fail(died);
      ready = css().includes("000000");
      if (!ready) await sleep(50);
    }
    if (!ready) fail("the first compile never produced out.css");
    await sleep(400);

    for (let i = 1; i <= ITERATIONS; i++) {
      const want = `${String(i).padStart(2, "0")}${String(i).padStart(2, "0")}${String(i).padStart(2, "0")}`;
      log = "";
      const t0 = performance.now();
      WRITERS[style](dep, `$c: #${want};\n`);
      let t1 = null;
      const deadline = Date.now() + 20000;
      while (Date.now() < deadline) {
        if (css().toLowerCase().includes(want)) {
          t1 = performance.now();
          break;
        }
        await sleep(1);
      }
      if (t1 === null) fail(`iteration ${i} never produced the new CSS`);
      samples.push(t1 - t0);
      // Long enough that the next save is a fresh burst, not a tail of
      // this one — otherwise the measurement measures the debounce twice.
      await sleep(400);
      if (/error/i.test(log)) errored++;
    }
  } finally {
    killed = true;
    proc.kill();
    rmSync(dir, { recursive: true, force: true });
  }

  samples.sort((a, b) => a - b);
  const at = (p) => samples[Math.min(samples.length - 1, Math.floor(samples.length * p))];
  return { style, n: samples.length, min: samples[0], med: at(0.5), p90: at(0.9), errored };
}

console.log(`watch latency: ${[cmd, ...pre].join(" ")}`);
console.log(`  ${ITERATIONS} saves per style, slow gap ${SLOW_GAP_MS}ms\n`);
console.log("  style   n    min     med     p90     saves that printed an error");
for (const style of ["atomic", "quick", "slow"]) {
  let r;
  try {
    r = await measure(style);
  } catch {
    // `measure` has already said what went wrong and set exitCode.
    process.exit(1);
  }
  const f = (x) => (x === undefined ? "  n/a" : `${x.toFixed(1)}ms`.padStart(7));
  console.log(
    `  ${style.padEnd(7)} ${String(r.n).padEnd(4)}${f(r.min)} ${f(r.med)} ${f(r.p90)}` +
      `     ${r.errored}/${r.n}${r.errored ? "  <- not a faster row" : ""}`,
  );
}
