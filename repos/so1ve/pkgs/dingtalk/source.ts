import * as fs from "node:fs/promises";
import * as path from "node:path";

import { defineSource, fetchurl, github, nix, type SourceFiles } from "nix-repin";

export default defineSource(async (source) => {
  const response = await fetch(
    `https://www.dingtalk.com/win/d/qd=linux_amd64`,
  );
  if (!response.ok) {
    throw new Error(`Failed to fetch DingTalk: ${response.status}`);
  }

  // The download redirect only accepts GET (HEAD returns 405). We only need
  // the final URL, so close the body before the large .deb is downloaded.
  const url = response.url;
  await response.body?.cancel();

  const match = new URL(url).pathname.match(
    /^\/dingtalk-desktop\/xc_dingtalk_update\/linux_deb\/Release\/com\.alibabainc\.dingtalk_([\d.]+)_amd64\.deb$/,
  )!;
  const version = match[1];

  const repository = "lzl200110/dingtalk-wayland-screenshare";
  const { date, rev } = await github.latestCommit({
    branch: "master",
    repository,
  });

  const skipApp = await source.shouldSkip(async () => {
    const existing = await fs
      .readFile(path.join(source.packageDirectory, "source.nix"), "utf8")
      .catch(() => "");

    return (
      existing.includes(`version = ${nix.string(version)};`) &&
      existing.includes(`url = ${nix.string(url)};`)
    );
  });

  const skipScreenshare = await source.shouldSkip(async () => {
    const existing = await fs
      .readFile(
        path.join(source.packageDirectory, "screenshare-source.nix"),
        "utf8",
      )
      .catch(() => "");

    return existing.includes(`rev = ${nix.string(rev)};`);
  });

  if (skipApp && skipScreenshare) {
    return false;
  }

  const files: SourceFiles = {};
  if (!skipApp) {
    Object.assign(
      files,
      await fetchurl({
        version,
        urls: {
          "x86_64-linux": url,
        },
      }),
    );
  }
  if (!skipScreenshare) {
    const screenshare = await github.prefetchArchive(repository, rev);
    files["screenshare-source.nix"] = nix.renderArchive(screenshare, {
      date,
      rev,
    });
  }

  return files;
});
