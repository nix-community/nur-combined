// Install what would be published and check `sasso/binary` end to end:
//   node napi/pack-test.mjs <platform-package-dir>
// <platform-package-dir> is what make-platform-package.mjs staged, binary
// included. The script packs it and wasm/npm (at the platform package's
// version, so the pairing check passes), installs both tarballs into an empty
// project with npm, and asserts, from inside that project:
//   - the tarball records `sasso` as mode 0755, and the install keeps it;
//   - `binaryPath()` from "sasso/binary" names that installed file;
//   - the file runs and reports the package's version;
//   - it compiles two corpus files to the same CSS as the installed addon.
// CI runs it on a package staged from this commit's build. The release
// workflow runs it on each leg's real package before `npm publish`, since
// nothing else exercises an install of the published files (#272).
import { execFileSync, spawnSync } from "node:child_process";
import { accessSync, constants, cpSync, mkdtempSync, readFileSync, realpathSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import assert from "node:assert/strict";

const platDir = resolve(process.argv[2] ?? "");
const plat = JSON.parse(readFileSync(join(platDir, "package.json"), "utf8"));
assert.ok(plat.files.includes("sasso"), `${plat.name} was staged without the binary`);
const repo = resolve(import.meta.dirname, "..");
const npm = process.platform === "win32" ? "npm.cmd" : "npm";
// Real path: resolution answers with one, and macOS's tmpdir is a symlink.
const work = realpathSync(mkdtempSync(join(tmpdir(), "sasso-pack-")));

// The main package at the platform package's version: a repo checkout's
// version is stale by design (the release workflow writes it from the tag).
const main = join(work, "main");
cpSync(join(repo, "wasm", "npm"), main, { recursive: true });
const mainPkg = JSON.parse(readFileSync(join(main, "package.json"), "utf8"));
mainPkg.version = plat.version;
delete mainPkg.optionalDependencies;
writeFileSync(join(main, "package.json"), JSON.stringify(mainPkg, null, 2) + "\n");

const pack = (dir) => {
  const out = JSON.parse(execFileSync(npm, ["pack", "--json", "--pack-destination", work], { cwd: dir, encoding: "utf8" }));
  // npm 11 prints an array of packs, npm 12 an object keyed by package name.
  return Array.isArray(out) ? out[0] : Object.values(out)[0];
};
const platTgz = pack(platDir);
const binEntry = platTgz.files.find((f) => f.path === "sasso");
assert.ok(binEntry, "the platform tarball has no sasso");
assert.equal(binEntry.mode & 0o777, 0o755, "the platform tarball records sasso as 0755");
const mainTgz = pack(main);
assert.ok(mainTgz.files.some((f) => f.path === "binary.mjs"), "the main tarball has no binary.mjs");
assert.ok(mainTgz.files.some((f) => f.path === "binary.d.ts"), "the main tarball has no binary.d.ts");

const project = join(work, "project");
cpSync(join(repo, "bench", "corpus", "gate"), join(project, "corpus"), { recursive: true });
writeFileSync(
  join(project, "package.json"),
  JSON.stringify({
    name: "sasso-pack-test",
    private: true,
    type: "module",
    dependencies: { sasso: `file:../${mainTgz.filename}`, [plat.name]: `file:../${platTgz.filename}` },
  }),
);
execFileSync(npm, ["install", "--no-audit", "--no-fund", "--loglevel=error"], { cwd: project, stdio: "inherit" });

const probe = (code) => execFileSync(process.execPath, ["--input-type=module", "-e", code], { cwd: project, encoding: "utf8" });
const bin = probe(`import { binaryPath } from "sasso/binary"; console.log(binaryPath());`).trim();
assert.equal(bin, join(project, "node_modules", plat.name, "sasso"), "binaryPath() names the installed binary");
accessSync(bin, constants.X_OK);
assert.ok(statSync(bin).mode & 0o100, "the installed binary is executable");

const version = execFileSync(bin, ["--version"], { encoding: "utf8" }).trim();
assert.equal(version, `sasso ${plat.version}`, "the binary is the package's version");
// The version marker the npm CLI reads instead of running a binary on PATH
// (`VERSION_MARKER` in src/main.rs). tests/version_marker.rs checks a debug
// build; this checks the release build that ships.
assert.ok(
  readFileSync(bin).includes(Buffer.from(`\0sasso-cli-version=${plat.version}\0`)),
  "the binary carries its version marker",
);

for (const file of ["extend_heavy.scss", "user_functions.scss"]) {
  const viaBinary = spawnSync(bin, ["--no-source-map", "--quiet", `corpus/${file}`], { cwd: project, encoding: "utf8" });
  assert.equal(viaBinary.status, 0, `${file}: the binary compiles it (${viaBinary.stderr})`);
  const viaAddon = probe(
    `import { compile, Logger } from "sasso/native"; process.stdout.write(compile("corpus/${file}", { logger: Logger.silent }).css);`,
  );
  assert.equal(viaBinary.stdout.trimEnd(), viaAddon.trimEnd(), `${file}: binary and addon agree`);
}
console.log(`ok: ${plat.name}@${plat.version} installs, and sasso/binary runs ${bin}`);
