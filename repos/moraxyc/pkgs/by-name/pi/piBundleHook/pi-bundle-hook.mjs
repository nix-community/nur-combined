import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";

let i = 2;
const nodeMajor = process.argv[i++];
const pkgDir = process.argv[i++];
const srcDir = process.argv[i++];
const outDirRel = process.argv[i++].replace(/^\.\//, "").replace(/\/+$/, "");
const format = process.argv[i++];
const minify = process.argv[i++] === "1";
const keepSources = process.argv[i++] === "1";
const keepNodeModules = process.argv[i++] === "1";
const splitting = process.argv[i++] === "1";
const inlineTypebox = process.argv[i++] === "1";

function takeList() {
  const n = Number(process.argv[i++]);
  const out = process.argv.slice(i, i + n);
  i += n;
  return out;
}

const explicitEntries = takeList();
const extraEsbuildFlags = takeList();
const extraCleanPaths = takeList();

const pkgJsonPath = path.join(pkgDir, "package.json");
const pkg = JSON.parse(fs.readFileSync(pkgJsonPath, "utf8"));
const entries = explicitEntries.length > 0 ? explicitEntries : pkg.pi?.extensions;
if (!Array.isArray(entries) || entries.length === 0) {
  throw new Error(`piBundleHook: no pi.extensions entries found in ${pkgJsonPath}`);
}

const distDir = path.join(pkgDir, outDirRel);
fs.mkdirSync(distDir, { recursive: true });

const baseFlags = [
  "--bundle",
  ...(minify ? ["--minify"] : []),
  "--platform=node",
  `--target=node${nodeMajor}`,
  `--format=${format}`,
  "--external:@earendil-works/*",
  "--external:@mariozechner/*",
  ...(inlineTypebox
    ? []
    : [
        "--external:typebox",
        "--external:typebox/*",
        "--external:@sinclair/typebox",
        "--external:@sinclair/typebox/*",
      ]),
  ...extraEsbuildFlags,
];

if (splitting) {
  // One run so entries share chunks. Outputs keep the entry stem and `.js`, so the
  // package's own pi.extensions and the paths it spawns workers from stay valid.
  if (format !== "esm") {
    throw new Error('piBundleHook: piBundleSplitting requires piBundleFormat = "esm"');
  }
  execFileSync(
    "esbuild",
    [
      ...entries.map((entry) => path.resolve(srcDir, entry)),
      ...baseFlags,
      "--splitting",
      `--outdir=${distDir}`,
      "--entry-names=[name]",
    ],
    { stdio: "inherit" },
  );
} else {
  const ext = format === "cjs" ? ".cjs" : ".mjs";
  const seen = new Set();
  const newExtensions = [];
  for (const entry of entries) {
    let outName;
    if (entries.length === 1) {
      outName = `index${ext}`;
    } else {
      const clean = entry.replace(/^\.\//, "");
      const parts = clean.split("/");
      const file = parts[parts.length - 1];
      const stem = file.replace(/\.[cm]?[jt]sx?$/, "");
      if (stem === "index" && parts.length > 2) {
        outName = `${parts[parts.length - 2]}${ext}`;
      } else {
        outName = `${stem}${ext}`;
      }
    }
    if (seen.has(outName)) {
      throw new Error(`piBundleHook: duplicate output name ${outDirRel}/${outName} for ${entry}`);
    }
    seen.add(outName);

    const outRel = `${outDirRel}/${outName}`;
    execFileSync(
      "esbuild",
      [path.resolve(srcDir, entry), ...baseFlags, `--outfile=${path.join(pkgDir, outRel)}`],
      { stdio: "inherit" },
    );
    newExtensions.push(`./${outRel}`);
  }
  pkg.pi ??= {};
  pkg.pi.extensions = newExtensions;
}
fs.writeFileSync(pkgJsonPath, `${JSON.stringify(pkg, null, 2)}\n`);

const rm = (rel) => fs.rmSync(path.join(pkgDir, rel), { recursive: true, force: true });

if (!keepSources) {
  for (const dir of ["src", "extensions", "test", "tests", "docs", "doc", "examples", ".github"]) {
    rm(dir);
  }
  for (const entry of entries) {
    const resolved = path.resolve(pkgDir, entry);
    const rel = path.relative(pkgDir, resolved);
    if (!rel.startsWith("..") && !rel.startsWith(`${outDirRel}/`) && rel !== outDirRel && rel !== ".") {
      fs.rmSync(resolved, { recursive: true, force: true });
    }
  }
}

for (const name of fs.readdirSync(pkgDir)) {
  if (/^(README|CHANGELOG|CONTRIBUTING|SECURITY|AGENTS|CLAUDE|CONTEXT).*\.md$/i.test(name)) {
    rm(name);
  }
}

for (const junk of [
  "tsconfig.json",
  "tsconfig.build.json",
  "vitest.config.ts",
  "vitest.config.js",
  "vitest.config.mts",
  "biome.json",
  "eslint.config.js",
  "eslint.config.mjs",
  "bun.lock",
  "package-lock.json",
  "pnpm-lock.yaml",
  "pnpm-workspace.yaml",
  ".editorconfig",
  ".gitattributes",
  ".gitignore",
]) {
  rm(junk);
}

if (keepNodeModules) {
  rm("node_modules/.bin");
  rm("node_modules/.package-lock.json");
  rm("node_modules/@types");
} else {
  rm("node_modules");
}

for (const p of extraCleanPaths) {
  rm(p);
}
