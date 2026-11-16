import { fetchurl } from "nix-repin";

const manifest =
  "https://antigravity-hub-auto-updater-974169037036.us-central1.run.app/manifest/latest-x64-linux.yml";
const baseUrl =
  "https://storage.googleapis.com/antigravity-public/antigravity-hub";

export default async () => {
  const text = await (await fetch(manifest)).text();
  const version = /^version:\s*([\d.]+)/m.exec(text)![1];
  const build = /antigravity-hub\/[\d.]+-(\d+)\//.exec(text)![1];

  return fetchurl({
    version,
    urls: {
      "x86_64-linux": `${baseUrl}/${version}-${build}/linux-x64/Antigravity.tar.gz`,
      "aarch64-linux": `${baseUrl}/${version}-${build}/linux-arm/Antigravity.tar.gz`,
    },
  });
};
