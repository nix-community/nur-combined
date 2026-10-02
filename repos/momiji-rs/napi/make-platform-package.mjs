// Stage one sasso-native platform package for npm publish:
//   node napi/make-platform-package.mjs <target> <version> <sasso.node> <out-dir> [<sasso>]
// The optional fifth argument is the release's `sasso` command-line binary
// for the same target. It ships beside the addon, mode 0755, and
// `sasso/binary` (wasm/npm/binary.mjs) hands its path to a caller that wants
// to spawn the compiler without node (#272). No install script uses it.
// <target> is a key of TARGETS (matches `sasso/native`'s runtime resolution in
// wasm/npm/native.mjs — keep the two lists in sync). The release workflow
// (.github/workflows/release-wasm.yml) calls this once per matrix leg, then
// `npm publish`es the produced directory.
import { chmodSync, cpSync, mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const TARGETS = {
  "darwin-arm64": { os: ["darwin"], cpu: ["arm64"] },
  "darwin-x64": { os: ["darwin"], cpu: ["x64"] },
  "linux-x64-gnu": { os: ["linux"], cpu: ["x64"], libc: ["glibc"] },
  "linux-arm64-gnu": { os: ["linux"], cpu: ["arm64"], libc: ["glibc"] },
};

const [target, version, binary, outDir, cli] = process.argv.slice(2);
const spec = TARGETS[target];
if (!spec || !version || !binary || !outDir) {
  console.error(`usage: node make-platform-package.mjs <${Object.keys(TARGETS).join("|")}> <version> <sasso.node> <out-dir> [<sasso>]`);
  process.exit(2);
}

const name = `sasso-native-${target}`;
mkdirSync(outDir, { recursive: true });
cpSync(binary, join(outDir, "sasso.node"));
const files = ["sasso.node"];
if (cli) {
  cpSync(cli, join(outDir, "sasso"));
  // npm records the mode in the tarball and package managers keep it, which
  // is how every platform package that carries an executable ships it.
  chmodSync(join(outDir, "sasso"), 0o755);
  files.push("sasso");
}
writeFileSync(
  join(outDir, "package.json"),
  JSON.stringify(
    {
      name,
      version,
      description: `Prebuilt sasso native addon${cli ? " and command-line binary" : ""} for ${target}. Install "sasso" and import "sasso/native" or "sasso/binary" — never depend on this package directly.`,
      main: "sasso.node",
      files,
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
  `# ${name}\n\nPrebuilt [sasso](https://www.npmjs.com/package/sasso) native addon${cli ? " and `sasso` command-line binary" : ""} for ${target}.\n` +
    `This package is an internal optionalDependency of \`sasso\` — install \`sasso\` and\n` +
    `\`import { compileString } from "sasso/native"\` (or \`binaryPath()\` from "sasso/binary")\n` +
    `instead of depending on it directly.\n`,
);
console.log(`staged ${name}@${version} -> ${outDir}`);
