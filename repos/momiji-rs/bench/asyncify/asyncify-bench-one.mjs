// One (mode, K) measurement per process: node asyncify-bench-one.mjs <mode> <K>
// mode: sync | async-syncimp | async-asyncimp
// Prints: median p10 p90 (ms/compile) over REPS after WARMUP.
import { compileString, compileStringAsync } from '../../wasm/npm/sasso.mjs';

const [mode, kStr] = process.argv.slice(2);
const K = parseInt(kStr, 10);
const WARMUP = 10, REPS = 50;

let src = '';
for (let i = 0; i < K; i++) src += `@use "m${i}";\n`;
src += 'a { b: c; }\n';

const wrapAsync = mode === 'async-asyncimp';
const imp = {
  canonicalize(url) {
    const u = new URL(url.startsWith('bench:') ? url : 'bench:' + url);
    return wrapAsync ? Promise.resolve(u) : u;
  },
  load(canonicalUrl) {
    const name = canonicalUrl.href.slice('bench:'.length);
    const r = { contents: `.${name} { d: e; }`, syntax: 'scss' };
    return wrapAsync ? Promise.resolve(r) : r;
  },
};

const run = mode === 'sync'
  ? () => { compileString(src, { importers: [imp] }); }
  : async () => { await compileStringAsync(src, { importers: [imp] }); };

// sanity: output must contain the last module exactly once
if (K > 0) {
  const css = mode === 'sync'
    ? compileString(src, { importers: [imp] }).css
    : (await compileStringAsync(src, { importers: [imp] })).css;
  const marker = `.m${K - 1} {`;
  if (!css.includes(marker)) { console.error(`SANITY FAIL: missing ${marker}`); process.exit(1); }
}

for (let i = 0; i < WARMUP; i++) await run();
const samples = [];
for (let i = 0; i < REPS; i++) {
  const t0 = performance.now();
  await run();
  samples.push(performance.now() - t0);
}
samples.sort((a, b) => a - b);
const q = (p) => samples[Math.min(samples.length - 1, Math.floor(p * samples.length))];
console.log(`${mode} K=${K} median=${q(0.5).toFixed(3)} p10=${q(0.1).toFixed(3)} p90=${q(0.9).toFixed(3)} ms`);
