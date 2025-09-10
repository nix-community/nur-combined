// fix.mjs
import fs from "fs";
import path from "path";
import https from "https";

const lockfilePath = path.resolve(process.cwd(), "package-lock.json");
const outPath = path.resolve(process.cwd(), "package-lock.fixed.json");

if (!fs.existsSync(lockfilePath)) {
  console.error("package-lock.json not found in current directory");
  process.exit(1);
}

const lockfile = JSON.parse(fs.readFileSync(lockfilePath, "utf-8"));
const packages = lockfile.packages || {};

function parsePkgNameFromPath(p) {
  if (p === "") return null;
  const parts = p.split("/");
  const nmIndex = parts.indexOf("node_modules");
  if (nmIndex === -1) return null;
  if (parts.length > nmIndex + 2 && parts[nmIndex + 1].startsWith("@")) {
    return parts[nmIndex + 1] + "/" + parts[nmIndex + 2];
  }
  if (parts.length > nmIndex + 1) {
    return parts[nmIndex + 1];
  }
  return null;
}

function fetchPackageInfo(name, version) {
  const url = `https://registry.npmjs.org/${encodeURIComponent(name)}/${encodeURIComponent(version)}`;
  return new Promise((resolve, reject) => {
    https
      .get(url, (res) => {
        if (res.statusCode !== 200) {
          reject(
            new Error(`Failed to fetch ${name}@${version}: ${res.statusCode}`),
          );
          return;
        }
        let data = "";
        res.on("data", (chunk) => (data += chunk));
        res.on("end", () => {
          try {
            const json = JSON.parse(data);
            resolve(json);
          } catch (e) {
            reject(e);
          }
        });
      })
      .on("error", reject);
  });
}

async function fixPackages() {
  let fixedCount = 0;
  for (const [pkgPath, pkgData] of Object.entries(packages)) {
    if (!pkgData.version) continue;
    if (pkgPath === "") continue;
    if (pkgData.resolved && pkgData.integrity) continue;

    const pkgName = parsePkgNameFromPath(pkgPath);
    if (!pkgName) {
      console.log(`Skipping ${pkgPath} (no valid package name)`);
      continue;
    }

    try {
      process.stdout.write(
        `Fetching info for ${pkgName}@${pkgData.version} ... `,
      );
      const info = await fetchPackageInfo(pkgName, pkgData.version);
      if (!info.dist || !info.dist.tarball || !info.dist.integrity) {
        console.warn(
          `No dist info for ${pkgName}@${pkgData.version}, skipping`,
        );
        continue;
      }

      pkgData.resolved = info.dist.tarball;
      pkgData.integrity = info.dist.integrity;

      fixedCount++;
      console.log("OK");
    } catch (e) {
      console.warn(
        `Failed to fetch ${pkgName}@${pkgData.version}: ${e.message}`,
      );
    }
  }
  console.log(`\nFixed ${fixedCount} packages`);
  fs.writeFileSync(outPath, JSON.stringify(lockfile, null, 2), "utf-8");
  console.log(`Saved fixed lockfile to ${outPath}`);
}

fixPackages().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
