import * as fs from "node:fs/promises";
import * as path from "node:path";

import { defineSource, fetchurl, nix } from "nix-repin";

async function release(software: string, architecture: string) {
  const response = await fetch(
    `https://client-webapi.oray.com/softwares/${software}?x64=1&versiontype=stable`,
  );
  if (!response.ok) {
    throw new Error(`Failed to fetch ${software}: ${response.status}`);
  }

  const metadata = (await response.json()) as {
    versionno: string;
    downloadurlmultiple: { url: string }[];
  };

  const download = metadata.downloadurlmultiple.find((download) =>
    download.url.endsWith(`_${architecture}.deb`),
  )!;
  const url = new URL(download.url);
  url.hostname = "dw.oray.com";

  return { version: metadata.versionno, url: url.toString() };
}

export default defineSource(async (source) => {
  const [x86_64, aarch64] = await Promise.all([
    release("SUNLOGIN_X_LINUX", "amd64"),
    release("SUNLOGIN_X_LINUX_ARM", "arm64"),
  ]);
  const urls = {
    "x86_64-linux": x86_64.url,
    "aarch64-linux": aarch64.url,
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

  return fetchurl({
    version: x86_64.version,
    urls,
  });
});
