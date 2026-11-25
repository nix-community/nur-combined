import fs from "node:fs";
import path from "node:path";

const pkgDir = process.argv[2];
if (!pkgDir) {
  throw new Error("Usage: fixup-host-deps.mjs <pkgDir>");
}

const HOST_PACKAGES = new Set([
  "@earendil-works/pi-agent-core",
  "@earendil-works/pi-ai",
  "@earendil-works/pi-coding-agent",
  "@earendil-works/pi-tui",
  "@mariozechner/pi-agent-core",
  "@mariozechner/pi-ai",
  "@mariozechner/pi-coding-agent",
  "@mariozechner/pi-tui",
  "@sinclair/typebox",
  "typebox",
]);

function isHostSpecifier(specifier) {
  if (HOST_PACKAGES.has(specifier)) return true;
  for (const pkg of HOST_PACKAGES) {
    if (specifier.startsWith(`${pkg}/`)) return true;
  }
  return false;
}

function listPackageEntries(dir) {
  const out = [];
  if (!fs.existsSync(dir)) return out;
  for (const name of fs.readdirSync(dir)) {
    if (name === ".bin" || name === ".pnpm") continue;
    const full = path.join(dir, name);
    if (name.startsWith("@")) {
      let stat;
      try {
        stat = fs.lstatSync(full);
      } catch {
        continue;
      }
      if (!stat.isDirectory()) continue;
      for (const sub of fs.readdirSync(full)) {
        out.push({ name: `${name}/${sub}`, full: path.join(full, sub), scopeDir: full });
      }
    } else {
      out.push({ name, full, scopeDir: null });
    }
  }
  return out;
}

function removeEmptyDir(dir) {
  if (!dir || !fs.existsSync(dir)) return;
  try {
    if (fs.readdirSync(dir).length === 0) {
      fs.rmdirSync(dir);
    }
  } catch {
    // ignore
  }
}

// 1. Move host-provided packages from dependencies to peerDependencies: "*"
const pkgJsonPath = path.join(pkgDir, "package.json");
const pkg = JSON.parse(fs.readFileSync(pkgJsonPath, "utf8"));
const movedHostPkgs = [];

if (pkg.dependencies && typeof pkg.dependencies === "object") {
  for (const dep of Object.keys(pkg.dependencies)) {
    if (HOST_PACKAGES.has(dep)) {
      pkg.peerDependencies ??= {};
      pkg.peerDependencies[dep] = "*";
      delete pkg.dependencies[dep];
      movedHostPkgs.push(dep);
    }
  }
}

fs.writeFileSync(pkgJsonPath, `${JSON.stringify(pkg, null, 2)}\n`);

// 2. Remove installed copies of host-provided packages and prune unreachable .pnpm entries
const nmDir = path.join(pkgDir, "node_modules");
for (const dep of movedHostPkgs) {
  const depPath = path.join(nmDir, ...dep.split("/"));
  fs.rmSync(depPath, { recursive: true, force: true });
  if (dep.includes("/")) {
    removeEmptyDir(path.join(nmDir, dep.split("/")[0]));
  }
}

const pnpmDir = path.join(nmDir, ".pnpm");
if (fs.existsSync(pnpmDir)) {
  const visited = new Set();
  const queue = [];

  const enqueueTarget = (linkPath) => {
    let real;
    try {
      real = fs.realpathSync(linkPath);
    } catch {
      return;
    }
    const rel = path.relative(pnpmDir, real);
    if (rel.startsWith("..") || path.isAbsolute(rel)) return;
    const entry = rel.split(path.sep)[0];
    if (!entry || entry === "node_modules") return;
    if (!visited.has(entry)) {
      visited.add(entry);
      queue.push(entry);
    }
  };

  for (const dep of Object.keys(pkg.dependencies ?? {})) {
    enqueueTarget(path.join(nmDir, ...dep.split("/")));
  }

  while (queue.length > 0) {
    const entry = queue.shift();
    const entryNm = path.join(pnpmDir, entry, "node_modules");
    for (const item of listPackageEntries(entryNm)) {
      enqueueTarget(item.full);
    }
  }

  for (const entry of fs.readdirSync(pnpmDir)) {
    if (entry === "node_modules") continue;
    if (!visited.has(entry)) {
      fs.rmSync(path.join(pnpmDir, entry), { recursive: true, force: true });
    }
  }

  const hoistedDir = path.join(pnpmDir, "node_modules");
  for (const item of listPackageEntries(hoistedDir)) {
    let keep = false;
    if (!HOST_PACKAGES.has(item.name)) {
      try {
        const real = fs.realpathSync(item.full);
        const rel = path.relative(pnpmDir, real);
        const entry = rel.split(path.sep)[0];
        keep = !rel.startsWith("..") && !path.isAbsolute(rel) && visited.has(entry);
      } catch {
        keep = false;
      }
    }
    if (!keep) {
      fs.rmSync(item.full, { recursive: true, force: true });
      removeEmptyDir(item.scopeDir);
    }
  }
}

// 3. Generate cli-stub-loader.mjs so `bin/remote-pi` can execute dist/index.js
// directly in Node without host-provided Pi runtime packages in node_modules.
const exportedNamesBySpec = new Map();
for (const pkgName of HOST_PACKAGES) {
  exportedNamesBySpec.set(pkgName, new Set());
}

function scanDist(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      scanDist(full);
    } else if (entry.isFile() && /\.[cm]?js$/.test(entry.name)) {
      const src = fs
        .readFileSync(full, "utf8")
        .replace(/\/\*[\s\S]*?\*\//g, "")
        .replace(/^\s*\/\/.*$/gm, "");
      const re = /\bimport\s+([^;]+?)\s+from\s+["']([^"']+)["']\s*;/g;
      let m;
      while ((m = re.exec(src)) !== null) {
        const clause = m[1].trim();
        const spec = m[2];
        if (!isHostSpecifier(spec)) continue;
        let names = exportedNamesBySpec.get(spec);
        if (!names) {
          names = new Set();
          exportedNamesBySpec.set(spec, names);
        }
        const braceMatch = clause.match(/\{([^}]*)\}/);
        if (braceMatch) {
          for (const part of braceMatch[1].split(",")) {
            const trimmed = part.trim().replace(/^type\s+/, "");
            if (!trimmed) continue;
            const exported = trimmed.split(/\s+as\s+/)[0].trim();
            if (exported) names.add(exported);
          }
        }
        const beforeBrace = braceMatch ? clause.slice(0, braceMatch.index).replace(/,$/, "").trim() : clause;
        if (beforeBrace && !beforeBrace.startsWith("*")) {
          names.add("default");
        }
      }
    }
  }
}

scanDist(path.join(pkgDir, "dist"));

const stubSources = {};
for (const [spec, names] of exportedNamesBySpec.entries()) {
  const parts = [];
  for (const name of [...names].sort()) {
    if (name === "default") {
      parts.push("export default undefined;");
    } else {
      parts.push(`export const ${name} = undefined;`);
    }
  }
  stubSources[spec] = parts.join("\n") || "export {};";
}

const loaderCode = `import { registerHooks } from "node:module";

const STUBS = ${JSON.stringify(stubSources, null, 2)};

function isHostSpecifier(specifier) {
  if (Object.hasOwn(STUBS, specifier)) return true;
  for (const key of Object.keys(STUBS)) {
    if (specifier.startsWith(\`\${key}/\`)) return true;
  }
  return false;
}

registerHooks({
  resolve(specifier, context, nextResolve) {
    if (isHostSpecifier(specifier)) {
      return { url: \`pi-host-stub:\${specifier}\`, shortCircuit: true };
    }
    return nextResolve(specifier, context);
  },
  load(url, context, nextLoad) {
    if (url.startsWith("pi-host-stub:")) {
      const specifier = url.slice("pi-host-stub:".length);
      return {
        format: "module",
        source: STUBS[specifier] ?? "export {};",
        shortCircuit: true,
      };
    }
    return nextLoad(url, context);
  },
});
`;

fs.writeFileSync(path.join(pkgDir, "cli-stub-loader.mjs"), loaderCode);
