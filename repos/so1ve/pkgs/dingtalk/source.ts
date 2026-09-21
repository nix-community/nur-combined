import { defineSource, fetchurl } from "nix-repin";

async function release(architecture: string) {
  const response = await fetch(
    `https://www.dingtalk.com/win/d/qd=linux_${architecture}`,
  );
  if (!response.ok) {
    throw new Error(
      `Failed to fetch DingTalk ${architecture}: ${response.status}`,
    );
  }

  // The download redirect only accepts GET (HEAD returns 405). We only need
  // the final URL, so close the body before the large .deb is downloaded.
  const url = response.url;
  await response.body?.cancel();

  const match = new URL(url).pathname.match(
    /^\/dingtalk-desktop\/xc_dingtalk_update\/linux_deb\/Release\/com\.alibabainc\.dingtalk_([\d.]+)_(amd64|arm64)\.deb$/,
  )!;

  return { version: match[1], url };
}

export default defineSource(async () => {
  const [x86_64, aarch64] = await Promise.all([
    release("amd64"),
    release("arm64"),
  ]);

  return fetchurl({
    version: x86_64.version,
    urls: {
      "x86_64-linux": x86_64.url,
      "aarch64-linux": aarch64.url,
    },
  });
});
