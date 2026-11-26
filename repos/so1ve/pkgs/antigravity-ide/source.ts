import * as fs from "node:fs/promises";
import * as path from "node:path";

import { defineSource, fetchurl, nix } from "nix-repin";

const api =
  "https://antigravity-ide-auto-updater-974169037036.us-central1.run.app/api/update";

const url = async (system: string) =>
  (
    (await (await fetch(`${api}/${system}/stable/latest`)).json()) as {
      url: string;
    }
  ).url.replaceAll(" ", "%20");

export default defineSource(async (source) => {
  const [x86_64, aarch64] = await Promise.all([
    url("linux-x64"),
    url("linux-arm64"),
  ]);
  const version = /stable\/([\d.]+)-/.exec(x86_64)![1];

  if (
    await source.shouldSkip(async () => {
      const existing = await fs
        .readFile(path.join(source.packageDirectory, "source.nix"), "utf8")
        .catch(() => "");

      return [x86_64, aarch64].every((u) =>
        existing.includes(`url = ${nix.string(u)};`),
      );
    })
  ) {
    return false;
  }

  return fetchurl({
    version,
    urls: {
      "x86_64-linux": { name: "antigravity-ide.tar.gz", url: x86_64 },
      "aarch64-linux": { name: "antigravity-ide.tar.gz", url: aarch64 },
    },
  });
});
