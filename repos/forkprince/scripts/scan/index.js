const { slug } = require("../updater/pkgs/text");
const fs = require("fs");

function warn(text) {
  console.error(`::warning::${text}`);
}

function join(list) {
  return list.join("\\n");
}

async function exec(command, ...args) {
  const child = Bun.spawn([command, ...args], { stdout: "pipe", stderr: "pipe" });

  const [output, error, status] = await Promise.all([
    new Response(child.stdout).text(),
    new Response(child.stderr).text(),
    child.exited
  ]);

  return { status, output, error };
}

function parse(result) {
  if (result.status !== 0) return null;

  try {
    return JSON.parse(result.output);
  } catch {
    return null;
  }
}

async function changes() {
  const { output } = await exec("git", "status", "--porcelain", "-uall", "--", "pkgs");

  const names = [...output.matchAll(/pkgs\/([^/\n]+)\//g)].map((match) => match[1]);

  return [...new Set(names)].sort();
}

function permitted() {
  const names = (process.env.ALLOW || "").split(",");

  if (fs.existsSync(".allow")) names.push(...fs.readFileSync(".allow", "utf8").split("\n").map((line) => line.replace(/#.*/, "")));

  return new Set(names.map((name) => name.trim()).filter(Boolean));
}

async function clamscan(target) {
  const result = await exec("clamscan", "--recursive", "--infected", "--no-summary", "--max-filesize=4G", "--max-scansize=4G", "--max-files=1000000", target);

  if (result.status === 0) return [];

  if (result.status !== 1) {
    warn(`clamscan failed on ${target} (${result.status}): ${result.error.trim()}`);

    return [];
  }

  return result.output
    .split("\n")
    .filter((line) => line.endsWith(" FOUND"))
    .map((line) => line.slice(line.lastIndexOf(": ") + 2, -" FOUND".length));
}

async function prefetch({ url, unpack }) {
  const args = ["store", "prefetch-file", encodeURI(decodeURI(url)), "--json", "--name", slug(url) || "download"];

  if (unpack) args.push("--unpack");

  return parse(await exec("nix", ...args))?.storePath || null;
}

async function targets(pkg) {
  const folder = `pkgs/${pkg}`;

  if (!fs.existsSync(`${folder}/version.json`)) {
    const attribute = fs
      .readFileSync("default.nix", "utf8")
      .match(new RegExp(`^[ \\t]*([\\w-]+)[ \\t]*=[ \\t]*lib\\.callPackage[ \\t]+\\./pkgs/${pkg}([ \\t]|$)`, "m"))?.[1];
    if (!attribute) return warn(`missing version or attribute for ${pkg}`), [];

    const result = await exec("nix", "build", "--no-link", "--print-out-paths", "--impure", "--expr", `(import ./default.nix { pkgs = import <nixpkgs> {}; }).${attribute}.src`);

    const path = result.status === 0 ? result.output.trim().split("\n").pop() : null;
    if (!path) return warn(`could not fetch src for ${pkg}`), [];

    return [{ label: `src (${attribute})`, path }];
  }

  const assets = parse(await exec("nix", "eval", "--json", "--impure", "--expr", `(import ./scripts/scan { folder = ./${folder}; })`));
  if (!assets) return warn(`could not list assets for ${pkg}`), [];

  const list = [];

  for (const asset of assets) {
    const path = await prefetch(asset);
    if (path) list.push({ label: `${asset.name} (${asset.kind}/${asset.id})`, path });
    else warn(`could not prefetch ${pkg}: ${asset.url}`);
  }

  return list;
}

async function main() {
  if ((await exec("clamscan", "--version")).status !== 0) return console.error("::error::ClamAV is not installed.");

  const modified = (await changes()).filter((pkg) => fs.existsSync(`pkgs/${pkg}`));
  if (modified.length === 0) return console.log("No changed packages.");

  const hits = [];
  for (const pkg of modified) {
    for (const { label, path } of await targets(pkg)) {
      for (const signature of await clamscan(path)) hits.push({ pkg, asset: label, signature });
    }
  }

  const allowed = permitted(), blocked = new Set();
  for (const { pkg, asset, signature } of hits) {
    console.error(`::error::Malware in ${pkg} (${asset}): ${signature}`);

    if (allowed.has(pkg)) warn(`${pkg} is allowlisted`);
    else blocked.add(pkg);
  }

  if (process.env.GITHUB_OUTPUT) fs.appendFileSync(process.env.GITHUB_OUTPUT, `blocked=${join([...blocked])}\ninfected=${join(hits.map((hit) => `${hit.pkg} | ${hit.asset} | ${hit.signature}`))}\n`);

  console.log(`Scanned ${modified.length} package(s): ${hits.length} detection(s), ${blocked.size} blocked.`);
}

await main();
