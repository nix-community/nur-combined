#!/usr/bin/env node
// gen_modular_corpus.mjs — deterministic generator for bench/corpus/modular/**.
//
// Emits an import-heavy multi-file SCSS corpus mirroring the shape of the real
// corpus in docs/HANDOFF_ASYNC_IMPORTER_PERF.md (a tailwind.scss compat layer:
// 36 loaded files, ~74 importer host calls, 132 KB expanded output):
//
//   _variables.scss / _mixins.scss     design tokens + shared mixins; the
//                                      `corpus-sanity` mixin emits the marker
//                                      rule `.sasso-corpus-sanity` that every
//                                      benchmark asserts on
//   components/_c<s>_<i>.scss          6 sections x 5 components of realistic
//                                      SCSS (nesting, @each over maps, color
//                                      functions, mixin includes)
//   _section<s>.scss                   one aggregator per section (@use x5)
//   vendor/lib/{_index,_reset,_grid}   a vendored package resolved via
//                                      loadPaths (benches pass
//                                      `loadPaths: [bench/corpus/modular/vendor]`
//                                      and entries say `@use "lib";`)
//   entry_01.scss .. entry_10.scss     bundler-style entries, each @use-ing
//                                      3-5 OVERLAPPING sections + lib + tokens
//                                      (multi-entry cold-build shape)
//
// entry_01 pulls sections 1-5 → 36 loaded files (1 entry + 2 token files +
// 3 vendor + 5 sections + 25 components; requirement: >= 25) and expands to
// ~80-150 KB of CSS.
//
// Fully deterministic: a fixed-seed LCG (no Math.random, no timestamps), so
// regeneration is byte-identical. The output is checked into git — like
// bench/corpus/generated/large.scss — and MANIFEST.json records
// {generatorVersion, seed, files, bytes, expectedMarker}.
//
// Run:  node bench/scripts/gen_modular_corpus.mjs
//       (rewrites bench/corpus/modular/ in place; humans read stderr)

import { mkdirSync, rmSync, writeFileSync } from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url)); // bench/scripts
const REPO_ROOT = path.resolve(HERE, "..", "..");
const OUT_DIR = path.join(REPO_ROOT, "bench", "corpus", "modular");

const GENERATOR_VERSION = 1;
const SEED = 0x53a55001; // fixed — regeneration must be byte-identical
const SECTIONS = 6;
const COMPONENTS_PER_SECTION = 5;
const ENTRIES = 10;
const EXPECTED_MARKER = ".sasso-corpus-sanity";

// ------------------------------------------------------------ seeded PRNG

// Numerical Recipes LCG over u32; Math.imul keeps the multiply in exact
// 32-bit space so every JS engine produces the same stream.
let lcgState = SEED >>> 0;
function rnd() {
  lcgState = (Math.imul(lcgState, 1664525) + 1013904223) >>> 0;
  return lcgState / 4294967296;
}
function int(lo, hi) {
  return lo + Math.floor(rnd() * (hi - lo + 1));
}
function pick(arr) {
  return arr[int(0, arr.length - 1)];
}
/** Deterministic Fisher-Yates shuffle of a copy; first `n` elements. */
function sample(arr, n) {
  const c = [...arr];
  for (let i = c.length - 1; i > 0; i--) {
    const j = int(0, i);
    [c[i], c[j]] = [c[j], c[i]];
  }
  return c.slice(0, n);
}
function hexChannel() {
  return int(32, 216).toString(16).padStart(2, "0");
}
function color() {
  return `#${hexChannel()}${hexChannel()}${hexChannel()}`;
}

// ------------------------------------------------------------- vocabulary

const PALETTE_NAMES = [
  "primary",
  "secondary",
  "success",
  "danger",
  "warning",
  "info",
  "accent",
  "neutral",
  "slate",
  "brand",
];

const KINDS = ["button", "card", "badge", "alert", "list", "nav", "form", "table", "toast", "panel"];

// Declaration pools for component bodies. Sampled WITHOUT replacement so a
// rule never repeats a property. All references resolve inside a component
// partial (`$tone`, `vars.*`, `mx.*`).
const BASE_DECLS = [
  "display: flex;",
  "align-items: center;",
  "justify-content: space-between;",
  "gap: map.get(vars.$spacing, 2);",
  "position: relative;",
  "padding: map.get(vars.$spacing, 2) map.get(vars.$spacing, 3);",
  "margin-bottom: map.get(vars.$spacing, 3);",
  "border: 1px solid color.adjust($tone, $lightness: 24%);",
  "border-radius: map.get(vars.$radii, md);",
  "background: color.mix($tone, #ffffff, 10%);",
  "color: color.scale($tone, $lightness: -42%);",
  "font-size: map.get(vars.$font-sizes, sm);",
  "font-weight: 500;",
  "line-height: 1.5;",
  "box-shadow: map.get(vars.$shadows, sm);",
  "transition: background-color 120ms ease, border-color 120ms ease;",
  "min-height: 2.5rem;",
  "overflow: hidden;",
];
const HOVER_DECLS = [
  "background: color.mix($tone, #ffffff, 18%);",
  "border-color: color.adjust($tone, $lightness: -6%);",
  "box-shadow: map.get(vars.$shadows, md);",
  "transform: translateY(-1px);",
];
const ACTIVE_DECLS = [
  "background: $tone;",
  "color: #ffffff;",
  "border-color: color.adjust($tone, $lightness: -12%);",
];
const LABEL_DECLS = [
  "font-weight: 600;",
  "letter-spacing: 0.01em;",
  "@include mx.truncate;",
  "color: color.scale($tone, $lightness: -55%);",
];
const ICON_DECLS = ["flex: 0 0 auto;", "width: 1.25em;", "height: 1.25em;", "opacity: 0.85;"];

// ---------------------------------------------------------------- writers

let filesWritten = 0;
let bytesWritten = 0;
function emit(rel, content) {
  const abs = path.join(OUT_DIR, rel);
  mkdirSync(path.dirname(abs), { recursive: true });
  writeFileSync(abs, content);
  filesWritten += 1;
  bytesWritten += Buffer.byteLength(content);
}

const GENERATED = "// GENERATED by bench/scripts/gen_modular_corpus.mjs — do not edit by hand.";

function indent(decls, n) {
  const pad = " ".repeat(n);
  return decls.map((d) => `${pad}${d}`).join("\n");
}

// ---------------------------------------------------------------- tokens

function variablesScss(palette) {
  const paletteLines = PALETTE_NAMES.map((n, i) => `  ${n}: ${palette[i]},`).join("\n");
  return `// _variables.scss — design tokens for the modular benchmark corpus.
${GENERATED}

$palette: (
${paletteLines}
);

$breakpoints: (
  sm: 640px,
  md: 768px,
  lg: 1024px,
  xl: 1280px,
);

$spacing: (
  0: 0,
  1: 0.25rem,
  2: 0.5rem,
  3: 0.75rem,
  4: 1rem,
  5: 1.5rem,
  6: 2rem,
  8: 3rem,
);

$radii: (
  none: 0,
  sm: 0.125rem,
  md: 0.375rem,
  lg: 0.75rem,
  pill: 9999px,
);

$shadows: (
  sm: (0 1px 2px rgba(15, 23, 42, 0.08)),
  md: (0 4px 12px rgba(15, 23, 42, 0.12)),
  lg: (0 12px 32px rgba(15, 23, 42, 0.16)),
);

$font-sizes: (
  xs: 0.75rem,
  sm: 0.875rem,
  md: 1rem,
  lg: 1.125rem,
  xl: 1.375rem,
  xxl: 1.75rem,
);

// Sanity marker: every entry stylesheet includes this mixin exactly once and
// every benchmark asserts the compiled CSS contains ".sasso-corpus-sanity"
// (see MANIFEST.json expectedMarker). A benchmark that silently compiles the
// wrong thing is worse than none.
@mixin corpus-sanity {
  .sasso-corpus-sanity {
    content: "ok";
  }
}
`;
}

function mixinsScss() {
  return `// _mixins.scss — layout/behavior mixins shared by every component partial.
${GENERATED}

@use "sass:color";
@use "sass:map";
@use "variables" as vars;

@mixin mq($bp) {
  @media (min-width: map.get(vars.$breakpoints, $bp)) {
    @content;
  }
}

@mixin button-base($bg, $fg: #ffffff) {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: map.get(vars.$spacing, 2);
  padding: map.get(vars.$spacing, 2) map.get(vars.$spacing, 4);
  border: 1px solid color.adjust($bg, $lightness: -8%);
  border-radius: map.get(vars.$radii, md);
  background: $bg;
  color: $fg;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 120ms ease, box-shadow 120ms ease;

  &:hover {
    background: color.adjust($bg, $lightness: -6%);
  }

  &:disabled {
    opacity: 0.55;
    cursor: not-allowed;
  }
}

@mixin card($pad: map.get(vars.$spacing, 4)) {
  padding: $pad;
  border: 1px solid rgba(15, 23, 42, 0.08);
  border-radius: map.get(vars.$radii, lg);
  background: #ffffff;
  box-shadow: map.get(vars.$shadows, sm);
  @content;
}

@mixin focus-ring($tone) {
  outline: 2px solid color.change($tone, $alpha: 0.55);
  outline-offset: 2px;
}

@mixin truncate {
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
}
`;
}

// ------------------------------------------------------------- components

function componentScss(s, i) {
  const kind = pick(KINDS);
  const tone = pick(PALETTE_NAMES);
  const base = `c${s}-${i}-${kind}`;
  const baseDecls = sample(BASE_DECLS, int(6, 9));
  const hoverDecls = sample(HOVER_DECLS, int(2, 3));
  const activeDecls = sample(ACTIVE_DECLS, 2);
  const labelDecls = sample(LABEL_DECLS, int(2, 3));
  const iconDecls = sample(ICON_DECLS, int(2, 3));
  const mixWeight = int(78, 92);
  const darken = int(8, 16);
  const padA = int(1, 2);
  const padB = int(3, 4);
  const mdPadA = int(2, 3);
  const mdPadB = int(4, 5);
  const cols = int(2, 4);

  return `// components/_c${s}_${i}.scss — "${kind}" component of section ${s}.
${GENERATED}

@use "sass:color";
@use "sass:map";
@use "../variables" as vars;
@use "../mixins" as mx;

$tone: map.get(vars.$palette, ${tone});

.${base} {
${indent(baseDecls, 2)}

  &:hover {
${indent(hoverDecls, 4)}
  }

  &:focus-visible {
    @include mx.focus-ring($tone);
  }

  &.is-active {
${indent(activeDecls, 4)}
  }

  .${base}__label {
${indent(labelDecls, 4)}
  }

  .${base}__icon {
${indent(iconDecls, 4)}
  }
}

@each $name, $value in vars.$palette {
  .${base}--#{$name} {
    background: color.mix($value, #ffffff, ${mixWeight}%);
    border-color: color.adjust($value, $lightness: -${darken}%);
    color: color.scale($value, $lightness: -48%);

    &:hover {
      background: $value;
      color: #ffffff;
    }
  }
}

@each $key, $size in vars.$font-sizes {
  .${base}--#{$key} {
    font-size: $size;
    padding: map.get(vars.$spacing, ${padA}) map.get(vars.$spacing, ${padB});
  }
}

@include mx.mq(md) {
  .${base} {
    padding: map.get(vars.$spacing, ${mdPadA}) map.get(vars.$spacing, ${mdPadB});
  }
}

@include mx.mq(lg) {
  .${base} {
    display: grid;
    grid-template-columns: repeat(${cols}, minmax(0, 1fr));
    gap: map.get(vars.$spacing, 3);
  }
}
`;
}

// --------------------------------------------------------------- sections

function sectionScss(s) {
  const uses = [];
  for (let i = 1; i <= COMPONENTS_PER_SECTION; i++) uses.push(`@use "components/c${s}_${i}";`);
  const gap = int(3, 5);
  return `// _section${s}.scss — aggregates the ${COMPONENTS_PER_SECTION} components of section ${s}.
${GENERATED}

@use "sass:map";
@use "variables" as vars;
@use "mixins" as mx;
${uses.join("\n")}

.section-${s} {
  display: flex;
  flex-direction: column;
  gap: map.get(vars.$spacing, ${gap});
}

@each $key, $value in vars.$spacing {
  .s${s}-stack-#{$key} > * + * {
    margin-top: $value;
  }
}

@include mx.mq(md) {
  .section-${s} {
    flex-direction: row;
    flex-wrap: wrap;
  }
}
`;
}

// ----------------------------------------------------------------- vendor

function vendorIndexScss() {
  return `// vendor/lib/_index.scss — entry point of the vendored "lib" package.
// Entries load it as \`@use "lib";\`, resolved through the benchmark's
// loadPaths: [bench/corpus/modular/vendor] (directory-index resolution).
${GENERATED}

@use "reset";
@use "grid";
`;
}

function vendorResetScss() {
  return `// vendor/lib/_reset.scss — minimal element reset for the vendored "lib".
${GENERATED}

*,
*::before,
*::after {
  box-sizing: border-box;
}

html {
  -webkit-text-size-adjust: 100%;
  line-height: 1.15;
}

body {
  margin: 0;
  font-family: system-ui, -apple-system, "Segoe UI", sans-serif;
  font-size: 1rem;
  line-height: 1.5;
  color: #1e293b;
  background: #ffffff;
}

h1,
h2,
h3,
h4,
h5,
h6 {
  margin: 0 0 0.5em;
  font-weight: 600;
  line-height: 1.25;
}

p {
  margin: 0 0 1em;
}

img,
svg,
video {
  display: block;
  max-width: 100%;
}

button,
input,
select,
textarea {
  font: inherit;
  color: inherit;
}

a {
  color: inherit;
  text-decoration: none;
}

ul[class],
ol[class] {
  margin: 0;
  padding: 0;
  list-style: none;
}

table {
  border-collapse: collapse;
  width: 100%;
}
`;
}

function vendorGridScss() {
  return `// vendor/lib/_grid.scss — 12-column flex grid (self-contained breakpoints).
${GENERATED}

@use "sass:math";

$columns: 12;
$gutter: 1.5rem;
$breakpoints: (
  sm: 640px,
  md: 768px,
  lg: 1024px,
  xl: 1280px,
);

.lib-container {
  width: 100%;
  margin-right: auto;
  margin-left: auto;
  padding-right: math.div($gutter, 2);
  padding-left: math.div($gutter, 2);
}

.lib-row {
  display: flex;
  flex-wrap: wrap;
  margin-right: math.div($gutter, -2);
  margin-left: math.div($gutter, -2);
}

.lib-row > * {
  padding-right: math.div($gutter, 2);
  padding-left: math.div($gutter, 2);
}

@for $i from 1 through $columns {
  .lib-col-#{$i} {
    flex: 0 0 auto;
    width: math.percentage(math.div($i, $columns));
  }
}

@each $bp, $min in $breakpoints {
  @media (min-width: $min) {
    .lib-container {
      max-width: $min - 32px;
    }

    @for $i from 1 through $columns {
      .lib-col-#{$bp}-#{$i} {
        flex: 0 0 auto;
        width: math.percentage(math.div($i, $columns));
      }
    }
  }
}
`;
}

// ---------------------------------------------------------------- entries

function entryScss(e, sections, cta) {
  const nn = String(e).padStart(2, "0");
  const uses = sections.map((s) => `@use "section${s}";`).join("\n");
  return `// entry_${nn}.scss — bundler-style entry #${e} of the modular benchmark corpus
// (sections ${sections.join(", ")} — entries deliberately overlap).
${GENERATED}

@use "sass:map";
@use "variables" as vars;
@use "mixins" as mx;
@use "lib"; // vendored package — resolves via loadPaths: [bench/corpus/modular/vendor]
${uses}

// Sanity marker: benchmarks fail hard unless the compiled CSS contains
// ".sasso-corpus-sanity".
@include vars.corpus-sanity;

.entry-${nn}-shell {
  margin: 0 auto;
  max-width: map.get(vars.$breakpoints, xl);
  padding: map.get(vars.$spacing, 3);

  @include mx.mq(lg) {
    padding: map.get(vars.$spacing, 6);
  }
}

.entry-${nn}-cta {
  @include mx.button-base(map.get(vars.$palette, ${cta}));
}
`;
}

// ------------------------------------------------------------------- main

rmSync(OUT_DIR, { recursive: true, force: true });
mkdirSync(OUT_DIR, { recursive: true });

// Draw order is fixed (tokens → components → sections → entries): the LCG
// stream, and therefore every output byte, depends only on SEED.
const palette = PALETTE_NAMES.map(() => color());
emit("_variables.scss", variablesScss(palette));
emit("_mixins.scss", mixinsScss());

for (let s = 1; s <= SECTIONS; s++) {
  for (let i = 1; i <= COMPONENTS_PER_SECTION; i++) {
    emit(path.join("components", `_c${s}_${i}.scss`), componentScss(s, i));
  }
}
for (let s = 1; s <= SECTIONS; s++) emit(`_section${s}.scss`, sectionScss(s));

emit(path.join("vendor", "lib", "_index.scss"), vendorIndexScss());
emit(path.join("vendor", "lib", "_reset.scss"), vendorResetScss());
emit(path.join("vendor", "lib", "_grid.scss"), vendorGridScss());

for (let e = 1; e <= ENTRIES; e++) {
  // entry_01 pins sections 1-5 (36 loaded files, the handoff corpus shape);
  // the rest take a random 3-5-section window over the 6 sections (overlap).
  let sections;
  if (e === 1) {
    sections = [1, 2, 3, 4, 5];
  } else {
    const k = int(3, 5);
    const start = int(1, SECTIONS);
    sections = [];
    for (let j = 0; j < k; j++) sections.push(((start - 1 + j) % SECTIONS) + 1);
    sections.sort((a, b) => a - b);
  }
  emit(`entry_${String(e).padStart(2, "0")}.scss`, entryScss(e, sections, pick(PALETTE_NAMES)));
}

// MANIFEST.json — counts cover the .scss corpus files (not the manifest).
const manifest = {
  generatorVersion: GENERATOR_VERSION,
  seed: SEED,
  files: filesWritten,
  bytes: bytesWritten,
  expectedMarker: EXPECTED_MARKER,
};
writeFileSync(path.join(OUT_DIR, "MANIFEST.json"), JSON.stringify(manifest, null, 2) + "\n");

process.stderr.write(
  `gen_modular_corpus: wrote ${filesWritten} .scss files (${bytesWritten} bytes) + MANIFEST.json to ${OUT_DIR}\n` +
    `  seed=0x${SEED.toString(16)} generatorVersion=${GENERATOR_VERSION} — regeneration is byte-identical\n` +
    `  size check: compile entry_01 with loadPaths [${path.join(OUT_DIR, "vendor")}] and expect 80-150 KB expanded CSS\n`,
);
