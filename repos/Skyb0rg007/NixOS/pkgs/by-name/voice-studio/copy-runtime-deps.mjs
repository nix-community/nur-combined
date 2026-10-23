// Copy the dependency closure of the given packages from a hoisted
// node_modules tree, preserving its layout.
// Usage: node copy-runtime-deps.mjs <root> <dest> <package>...
import { cpSync, existsSync, readFileSync } from 'node:fs';
import { dirname, join, relative } from 'node:path';

const [root, dest, ...wanted] = process.argv.slice(2);
const seen = new Set();

function locate(fromDir, name) {
  for (let dir = fromDir; ; dir = dirname(dir)) {
    const candidate = join(dir, 'node_modules', name);
    if (existsSync(join(candidate, 'package.json'))) return candidate;
    if (dir === root || dir === dirname(dir)) return null;
  }
}

function visit(fromDir, name, optional) {
  const pkgDir = locate(fromDir, name);
  if (!pkgDir) {
    if (optional) return;
    throw new Error(`cannot resolve ${name} from ${fromDir}`);
  }
  if (seen.has(pkgDir)) return;
  seen.add(pkgDir);
  const manifest = JSON.parse(readFileSync(join(pkgDir, 'package.json'), 'utf8'));
  for (const dep of Object.keys(manifest.dependencies ?? {})) visit(pkgDir, dep, false);
  for (const dep of Object.keys(manifest.optionalDependencies ?? {})) visit(pkgDir, dep, true);
}

for (const name of wanted) visit(root, name, false);
for (const pkgDir of seen) {
  cpSync(pkgDir, join(dest, relative(root, pkgDir)), {
    recursive: true,
    filter: (src) => src === pkgDir || !src.startsWith(join(pkgDir, 'node_modules')),
  });
}
console.log(`copied ${seen.size} packages`);
