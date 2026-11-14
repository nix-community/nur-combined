import { defineSource, fetchurl, github, nix } from "nix-repin";

export default defineSource(async () => {
  const response = await fetch(
    `https://www.dingtalk.com/win/d/qd=linux_amd64`,
  );
  if (!response.ok) {
    throw new Error(
      `Failed to fetch DingTalk: ${response.status}`,
    );
  }

  // The download redirect only accepts GET (HEAD returns 405). We only need
  // the final URL, so close the body before the large .deb is downloaded.
  const url = response.url;
  await response.body?.cancel();

  const match = new URL(url).pathname.match(
    /^\/dingtalk-desktop\/xc_dingtalk_update\/linux_deb\/Release\/com\.alibabainc\.dingtalk_([\d.]+)_amd64\.deb$/,
  )!;

  const dingtalk = await fetchurl({
    version: match[1],
    urls: {
      "x86_64-linux": url,
    },
  });
  const repository = "lzl200110/dingtalk-wayland-screenshare";
  const { date, rev } = await github.latestCommit({
    branch: "master",
    repository,
  });
  const screenshare = await github.prefetchArchive(repository, rev);

  return {
    ...dingtalk,
    "screenshare-source.nix": nix.renderArchive(screenshare, { date, rev }),
  };
});
