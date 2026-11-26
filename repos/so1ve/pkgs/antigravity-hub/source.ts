import * as fs from "node:fs/promises";
import * as path from "node:path";

import { defineSource, fetchurl, nix } from "nix-repin";

const manifest =
  "https://antigravity-hub-auto-updater-974169037036.us-central1.run.app/manifest/latest-x64-linux.yml";
const baseUrl =
  "https://storage.googleapis.com/antigravity-public/antigravity-hub";

export default defineSource(async (source) => {
  const text = await (await fetch(manifest)).text();
  const version = /^version:\s*([\d.]+)/m.exec(text)![1];
  const build = /antigravity-hub\/[\d.]+-(\d+)\//.exec(text)![1];
  const urls = {
    "x86_64-linux": `${baseUrl}/${version}-${build}/linux-x64/Antigravity.tar.gz`,
    "aarch64-linux": `${baseUrl}/${version}-${build}/linux-arm/Antigravity.tar.gz`,
  };

  if (
    await source.shouldSkip(async () => {
      const existing = await fs
        .readFile(path.join(source.packageDirectory, "source.nix"), "utf8")
        .catch(() => "");

      return Object.values(urls).every((url) =>
        existing.includes(`url = ${nix.string(url)};`),
      );
    })
  ) {
    return false;
  }

  return fetchurl({ version, urls });
});
