// Stage one sasso-native platform package for npm publish:
//   node napi/make-platform-package.mjs <target> <version> <binary> <out-dir>
// <target> is a key of TARGETS (matches `sasso/native`'s runtime resolution in
// wasm/npm/native.mjs — keep the two lists in sync). The release workflow
// (.github/workflows/release-wasm.yml) calls this once per matrix leg, then
// `npm publish`es the produced directory.
import { cpSync, mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const TARGETS = {
  "darwin-arm64": { os: ["darwin"], cpu: ["arm64"] },
  "darwin-x64": { os: ["darwin"], cpu: ["x64"] },
  "linux-x64-gnu": { os: ["linux"], cpu: ["x64"], libc: ["glibc"] },
  "linux-arm64-gnu": { os: ["linux"], cpu: ["arm64"], libc: ["glibc"] },
};

const [target, version, binary, outDir] = process.argv.slice(2);
const spec = TARGETS[target];
if (!spec || !version || !binary || !outDir) {
  console.error(`usage: node make-platform-package.mjs <${Object.keys(TARGETS).join("|")}> <version> <sasso.node> <out-dir>`);
  process.exit(2);
}

const name = `sasso-native-${target}`;
mkdirSync(outDir, { recursive: true });
cpSync(binary, join(outDir, "sasso.node"));
writeFileSync(
  join(outDir, "package.json"),
  JSON.stringify(
    {
      name,
      version,
      description: `Prebuilt sasso native addon for ${target}. Install "sasso" and import "sasso/native" — never depend on this package directly.`,
      main: "sasso.node",
      files: ["sasso.node"],
      ...spec,
      license: "MIT OR Apache-2.0",
      repository: { type: "git", url: "git+https://github.com/momiji-rs/sasso.git", directory: "napi" },
      engines: { node: ">=18" },
      publishConfig: { access: "public" },
    },
    null,
    2,
  ) + "\n",
);
writeFileSync(
  join(outDir, "README.md"),
  `# ${name}\n\nPrebuilt [sasso](https://www.npmjs.com/package/sasso) native addon binary for ${target}.\n` +
    `This package is an internal optionalDependency of \`sasso\` — install \`sasso\` and\n` +
    `\`import { compileString } from "sasso/native"\` instead of depending on it directly.\n`,
);
console.log(`staged ${name}@${version} -> ${outDir}`);
