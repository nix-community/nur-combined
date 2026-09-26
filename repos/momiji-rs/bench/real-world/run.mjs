#!/usr/bin/env node
// Real-world corpus harness: sparse-clone pinned well-known Sass projects,
// compile each with dart-sass (ground truth) and sasso, verify output parity
// through the shared normalize/canon pipeline, and benchmark wall time with
// hyperfine. See projects.json for the vetting criteria and exclusions.
//
//   node run.mjs setup    clone repos at pinned SHAs, materialize prep entries
//   node run.mjs check    compile with both engines, report errors + parity
//   node run.mjs bench    hyperfine dart-sass vs sasso per project
//   node run.mjs report   render results/ into real_world.md
//   node run.mjs all      setup + check + bench + report
//
// Optional: --only=<name>[,<name>] restricts check/bench to listed projects.

import { execFileSync, spawnSync } from 'node:child_process';
import {
  existsSync, mkdirSync, readFileSync, writeFileSync, symlinkSync, rmSync,
  readdirSync, statSync,
} from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..', '..');
const REPOS = path.join(HERE, 'repos');
const PREP = path.join(HERE, 'prep');
const OUT = path.join(HERE, 'out');
const RESULTS = path.join(HERE, 'results');
const SASSO = path.join(ROOT, 'target', 'release', 'sasso');
const DART = path.join(HERE, 'node_modules', '.bin', 'sass');
const NORMALIZE = path.join(ROOT, 'bench', 'scripts', 'normalize_css.sh');
const CANON = path.join(ROOT, 'bench', 'scripts', 'canon_css.py');

const manifest = JSON.parse(readFileSync(path.join(HERE, 'projects.json'), 'utf8'));
const argv = process.argv.slice(2);
const cmd = argv.find((a) => !a.startsWith('--')) ?? 'all';
const onlyArg = argv.find((a) => a.startsWith('--only='));
const only = onlyArg ? onlyArg.slice('--only='.length).split(',') : null;
const projects = manifest.projects.filter((p) => !only || only.includes(p.name));

for (const d of [REPOS, PREP, OUT, RESULTS]) mkdirSync(d, { recursive: true });

const sh = (cmdline, opts = {}) =>
  spawnSync('bash', ['-c', cmdline], { encoding: 'utf8', maxBuffer: 512 * 1024 * 1024, ...opts });

// ---------------------------------------------------------------- resolution

function repoDir(p) { return path.join(REPOS, p.name); }
function prepDir(p) { return path.join(PREP, p.name); }
function shimDir(p) { return path.join(PREP, `${p.name}-shim`); }

function entryPath(p) {
  return p.entry.startsWith('@prep/')
    ? path.join(prepDir(p), p.entry.slice('@prep/'.length))
    : path.join(repoDir(p), p.entry);
}

function loadPathArgs(p, flag) {
  return (p.loadPaths ?? []).flatMap((lp) => {
    const dir = lp === '@shim' ? shimDir(p)
      : lp === '@node_modules' ? path.join(HERE, 'node_modules')
      : path.join(repoDir(p), lp);
    return [flag, dir];
  });
}

// --------------------------------------------------------------------- setup

function setup() {
  for (const p of projects) {
    const dir = repoDir(p);
    if (!existsSync(path.join(dir, '.git'))) {
      console.log(`== clone ${p.name} @ ${p.sha.slice(0, 7)}`);
      mkdirSync(dir, { recursive: true });
      execFileSync('git', ['-C', dir, 'init', '-q']);
      execFileSync('git', ['-C', dir, 'remote', 'add', 'origin', p.repo]);
      if (p.sparse?.length) {
        execFileSync('git', ['-C', dir, 'sparse-checkout', 'set', ...p.sparse]);
      }
      execFileSync('git', ['-C', dir, 'fetch', '-q', '--depth', '1', 'origin', p.sha]);
      execFileSync('git', ['-C', dir, 'checkout', '-q', 'FETCH_HEAD']);
    } else {
      console.log(`== ${p.name} already cloned`);
    }

    if (p.shims) {
      for (const [name, target] of Object.entries(p.shims)) {
        const link = path.join(shimDir(p), name);
        mkdirSync(path.dirname(link), { recursive: true });
        if (!existsSync(link)) symlinkSync(path.join(dir, target), link);
      }
    }

    if (p.prep?.write) {
      mkdirSync(prepDir(p), { recursive: true });
      writeFileSync(path.join(prepDir(p), p.prep.write.file), p.prep.write.content);
    }
    if (p.prep?.jekyll) {
      const { from, file, liquidDefault } = p.prep.jekyll;
      let src = readFileSync(path.join(dir, from), 'utf8');
      src = src.replace(/^---[\s\S]*?---\s*/, ''); // strip Jekyll front matter
      // Liquid `{%- ... -%}` hyphens trim adjacent whitespace; dev mode drops
      // the whole if-block, so eat the surrounding gap along with it.
      src = src.replace(/\s*\{%-\s*if[\s\S]*?endif\s*-%\}\s*/g, '');
      src = src.replace(/\{%-?\s*if[\s\S]*?endif\s*-?%\}/g, ''); // non-trimming if-blocks
      src = src.replace(/\{%-?[\s\S]*?-?%\}/g, ''); // drop remaining Liquid tags
      src = src.replace(/\{\{[^}]*\}\}/g, liquidDefault); // resolve Liquid exprs
      mkdirSync(prepDir(p), { recursive: true });
      writeFileSync(path.join(prepDir(p), file), src);
    }
    if (p.prep?.linkNodeModules) {
      // Repo-relative `node_modules/...` imports resolve against the shared
      // harness install (deps pinned in bench/real-world/package.json).
      const link = path.join(dir, 'node_modules');
      if (!existsSync(link)) symlinkSync(path.join(HERE, 'node_modules'), link);
    }
  }
}

// --------------------------------------------------------------------- check

function compileCmd(p, engine, outFile) {
  const entry = entryPath(p);
  if (engine === 'dart') {
    return [DART, ...loadPathArgs(p, '--load-path'),
      '--style=expanded', '--no-source-map', '--quiet', entry, outFile];
  }
  // Same work as the dart-sass line: no source map (sasso, like dart, writes
  // one by default for a file target), no warnings.
  return [SASSO, ...loadPathArgs(p, '-I'), '-s', 'expanded', '--no-source-map', '--quiet', '-o', outFile, entry];
}

function runCompile(p, engine) {
  const outFile = path.join(OUT, `${p.name}.${engine}.css`);
  const [bin, ...args] = compileCmd(p, engine, outFile);
  const r = spawnSync(bin, args, { encoding: 'utf8' });
  return { ok: r.status === 0, outFile, stderr: (r.stderr ?? '').trim() };
}

function parity(p) {
  const a = path.join(OUT, `${p.name}.dart.css`);
  const b = path.join(OUT, `${p.name}.sasso.css`);
  // Tier 0: raw byte equality — the strongest claim, checked first.
  if (readFileSync(a).equals(readFileSync(b))) {
    return { status: 'byte-identical', diffLines: 0 };
  }
  const canon = (f) => {
    const r = sh(`bash ${JSON.stringify(NORMALIZE)} < ${JSON.stringify(f)} | python3 ${JSON.stringify(CANON)}`);
    if (r.status !== 0) throw new Error(`canon failed for ${f}: ${r.stderr}`);
    return r.stdout;
  };
  const ca = canon(a); const cb = canon(b);
  if (ca === cb) return { status: 'identical (canonical)', diffLines: 0 };
  writeFileSync(path.join(OUT, `${p.name}.dart.canon.css`), ca);
  writeFileSync(path.join(OUT, `${p.name}.sasso.canon.css`), cb);
  // Second tier: selector order inside a comma-separated selector list has no
  // cascade effect (same rule, per-selector specificity). dart-sass and sasso
  // order @extend-generated selectors differently; classify that separately
  // from genuine divergence.
  const sortSel = (txt) => txt.split('\n').map((ln) =>
    ln.endsWith('{') ? ln.slice(0, -1).split(',').sort().join(',') + '{' : ln,
  ).join('\n');
  const sa = sortSel(ca); const sb = sortSel(cb);
  if (sa === sb) {
    const la = ca.split('\n'); const lb = cb.split('\n');
    let rules = 0;
    for (let i = 0; i < la.length; i += 1) if (la[i] !== lb[i]) rules += 1;
    return { status: 'selector-order only', diffLines: rules };
  }
  // Third tier: also ignore comment placement/retention (dart-sass keeps loud
  // comments inline inside @extend-merged selector lists; sasso relocates or
  // drops them). No effect on computed styles.
  const stripComments = (txt) => sortSel(
    txt.replace(/\/\*[^]*?\*\//g, '').split('\n').map((l) => l.trim()).filter(Boolean).join('\n'),
  );
  if (stripComments(ca) === stripComments(cb)) {
    return { status: 'comments/selector-order only', diffLines: 0 };
  }
  const d = sh(`diff ${JSON.stringify(path.join(OUT, `${p.name}.dart.canon.css`))} ${JSON.stringify(path.join(OUT, `${p.name}.sasso.canon.css`))} | grep -c '^[<>]'`);
  return { status: 'DIFFERS', diffLines: parseInt(d.stdout.trim(), 10) || 0 };
}

function check() {
  const report = [];
  for (const p of projects) {
    if (p.skip) {
      console.log(`== ${p.name}: SKIP (${p.skip.split('.')[0]})`);
      report.push({ name: p.name, skip: p.skip });
      continue;
    }
    const dart = runCompile(p, 'dart');
    const sasso = runCompile(p, 'sasso');
    let par = null;
    if (dart.ok && sasso.ok) {
      try { par = parity(p); } catch (e) { par = { status: `canon error: ${e.message.slice(0, 120)}`, diffLines: 0 }; }
    }
    report.push({ name: p.name, dart, sasso, parity: par });
    const dstat = dart.ok ? 'ok' : 'FAIL';
    const sstat = sasso.ok ? 'ok' : 'FAIL';
    console.log(`== ${p.name}: dart=${dstat} sasso=${sstat} parity=${par ? `${par.status}${par.diffLines ? ` (${par.diffLines} lines)` : ''}` : 'n/a'}`);
    if (!dart.ok) console.log(`   dart stderr: ${dart.stderr.split('\n').slice(0, 6).join('\n   ')}`);
    if (!sasso.ok) console.log(`   sasso stderr: ${sasso.stderr.split('\n').slice(0, 6).join('\n   ')}`);
  }
  writeFileSync(path.join(RESULTS, 'check.json'), JSON.stringify(report, null, 2));
  return report;
}

// --------------------------------------------------------------------- bench

function benchOne(p) {
  const dartCmd = compileCmd(p, 'dart', path.join(OUT, 'bench-dart.css')).map((a) => JSON.stringify(a)).join(' ');
  const sassoCmd = compileCmd(p, 'sasso', path.join(OUT, 'bench-sasso.css')).map((a) => JSON.stringify(a)).join(' ');
  const json = path.join(RESULTS, `${p.name}.json`);
  execFileSync('hyperfine', [
    '--warmup', '2', '--min-runs', '10',
    '--export-json', json,
    '-n', 'dart-sass', `${dartCmd} 2>/dev/null`,
    '-n', 'sasso', `${sassoCmd} 2>/dev/null`,
  ], { stdio: 'inherit' });
}

function bench() {
  const checks = JSON.parse(readFileSync(path.join(RESULTS, 'check.json'), 'utf8'));
  // Startup baseline: empty input, measures pure process/VM startup cost.
  const empty = path.join(PREP, 'empty.scss');
  writeFileSync(empty, '');
  execFileSync('hyperfine', [
    '--warmup', '2', '--min-runs', '10',
    '--export-json', path.join(RESULTS, '_startup.json'),
    '-n', 'dart-sass', `${JSON.stringify(DART)} --style=expanded --no-source-map --quiet ${JSON.stringify(empty)} ${JSON.stringify(path.join(OUT, 'bench-dart.css'))} 2>/dev/null`,
    '-n', 'sasso', `${JSON.stringify(SASSO)} -s expanded --no-source-map --quiet -o ${JSON.stringify(path.join(OUT, 'bench-sasso.css'))} ${JSON.stringify(empty)} 2>/dev/null`,
  ], { stdio: 'inherit' });
  for (const p of projects) {
    if (p.skip) continue;
    const c = checks.find((x) => x.name === p.name);
    if (!c?.dart.ok || !c?.sasso.ok) {
      console.log(`== skip bench ${p.name} (compile failed: dart=${c?.dart.ok} sasso=${c?.sasso.ok})`);
      continue;
    }
    console.log(`== bench ${p.name}`);
    benchOne(p);
  }
}

// -------------------------------------------------------------------- report

function sourceStats(p) {
  let files = 0; let bytes = 0;
  const walk = (d) => {
    for (const e of readdirSync(d)) {
      const f = path.join(d, e);
      let st;
      try { st = statSync(f); } catch { continue; } // broken symlink (sparse checkout)
      if (st.isDirectory()) { if (e !== '.git' && e !== 'node_modules') walk(f); }
      else if (/\.(scss|sass)$/.test(e)) { files += 1; bytes += st.size; }
    }
  };
  walk(repoDir(p));
  return { files, kb: Math.round(bytes / 1024) };
}

function fmtMs(s) { return `${(s * 1000).toFixed(0)} ms`; }

function report() {
  const checks = JSON.parse(readFileSync(path.join(RESULTS, 'check.json'), 'utf8'));
  const dartVer = sh(`${JSON.stringify(DART)} --version`).stdout.trim();
  const sassoVer = sh(`${JSON.stringify(SASSO)} --version`).stdout.trim();
  const rows = [];
  let startupNote = '';
  const startupFile = path.join(RESULTS, '_startup.json');
  if (existsSync(startupFile)) {
    const s = JSON.parse(readFileSync(startupFile, 'utf8')).results;
    const d = s.find((r) => r.command.includes('dart') || s.indexOf(r) === 0);
    const so = s.find((r) => r !== d);
    startupNote = `Process-startup baseline (empty input): dart-sass ${fmtMs(d.median)}, sasso ${fmtMs(so.median)}. Full-invocation medians below include this cost — it is what a CLI/CI user experiences per call.`;
  }
  for (const p of manifest.projects) {
    const c = checks.find((x) => x.name === p.name);
    const jf = path.join(RESULTS, `${p.name}.json`);
    const stats = existsSync(repoDir(p)) ? sourceStats(p) : { files: '?', kb: '?' };
    let dartMs = '—'; let sassoMs = '—'; let speedup = '—';
    if (existsSync(jf)) {
      const r = JSON.parse(readFileSync(jf, 'utf8')).results;
      const d = r.find((x) => x.command.startsWith('"' + DART) || r.indexOf(x) === 0);
      const so = r.find((x) => x !== d);
      dartMs = fmtMs(d.median); sassoMs = fmtMs(so.median);
      speedup = `${(d.median / so.median).toFixed(1)}×`;
    }
    const par = p.skip ? 'excluded (see projects.json)'
      : c?.parity ? c.parity.status + (c.parity.diffLines ? ` (${c.parity.diffLines})` : '')
      : (c && (!c.dart.ok || !c.sasso.ok) ? `compile fail (dart=${c.dart.ok ? 'ok' : 'FAIL'}, sasso=${c.sasso.ok ? 'ok' : 'FAIL'})` : '—');
    rows.push(`| [${p.name}](${p.repo}) | ${String(p.stars).replace(/\B(?=(\d{3})+(?!\d))/g, ',')} | \`${p.sha.slice(0, 7)}\` | ${stats.files} files / ${stats.kb} KB | ${dartMs} | ${sassoMs} | **${speedup}** | ${par} |`);
  }
  const md = `# Real-world corpus: sasso vs dart-sass

Well-known open-source Sass codebases, each pinned to its default-branch HEAD
as of 2026-07-04 (batch 2: 2026-07-05) and verified active (last commit within
six months). Each entry
point is compiled standalone with both engines; output parity is checked after
whitespace + color-serialization canonicalization (\`bench/scripts/\`).

- dart-sass: \`${dartVer}\` (npm \`sass\`, invoked via its CLI)
- sasso: \`${sassoVer}\` (release build, this repo)
- timing: hyperfine, 2 warmup + ≥10 runs, full CLI invocation (median)

${startupNote}

| project | stars | pin | sass sources | dart-sass | sasso | speedup | output parity |
|---|---|---|---|---|---|---|---|
${rows.join('\n')}

Regenerate: \`node bench/real-world/run.mjs all\`.
`;
  writeFileSync(path.join(HERE, 'real_world.md'), md);
  console.log(md);
}

// ---------------------------------------------------------------------- main

switch (cmd) {
  case 'setup': setup(); break;
  case 'check': check(); break;
  case 'bench': bench(); break;
  case 'report': report(); break;
  case 'all': setup(); check(); bench(); report(); break;
  default:
    console.error(`unknown command: ${cmd}`);
    process.exit(1);
}
