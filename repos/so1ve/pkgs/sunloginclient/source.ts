import { defineSource, fetchurl } from "nix-repin";

async function release(software: string, architecture: string) {
  const response = await fetch(
    `https://client-webapi.oray.com/softwares/${software}?x64=1&versiontype=stable`,
  );
  if (!response.ok) {
    throw new Error(`Failed to fetch ${software}: ${response.status}`);
  }

  const metadata = await response.json() as {
    versionno: string;
    downloadurlmultiple: { url: string }[];
  };

  const download = metadata.downloadurlmultiple.find((download) =>
    download.url.endsWith(`_${architecture}.deb`)
  )!;

  return { version: metadata.versionno, url: download.url };
}

export default defineSource(async () => {
  const [x86_64, aarch64] = await Promise.all([
    release("SUNLOGIN_X_LINUX", "amd64"),
    release("SUNLOGIN_X_LINUX_ARM", "arm64"),
  ]);

  return fetchurl({
    version: x86_64.version,
    urls: {
      "x86_64-linux": x86_64.url,
      "aarch64-linux": aarch64.url,
    },
  });
});
