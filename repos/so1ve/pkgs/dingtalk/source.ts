import { defineSource, fetchurl, github, nix } from "nix-repin";

const dingtalk = async () => {
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

  return fetchurl({
    version: match[1],
    urls: {
      "x86_64-linux": url,
    },
  });
};

const screenshare = defineSource(async (source) => {
  const repository = "lzl200110/dingtalk-wayland-screenshare";
  const { date, rev } = await github.latestCommit({
    branch: "master",
    repository,
  });
  if (
    await source.shouldSkip(() =>
      source.matches({ rev }, "screenshare-source.nix"),
    )
  ) {
    return;
  }

  const archive = await github.prefetchArchive(repository, rev);

  return {
    "screenshare-source.nix": nix.renderArchive(archive, { date, rev }),
  };
});

export default defineSource(dingtalk, screenshare);
