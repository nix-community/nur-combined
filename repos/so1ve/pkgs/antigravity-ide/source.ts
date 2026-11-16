import { fetchurl } from "nix-repin";

const api =
  "https://antigravity-ide-auto-updater-974169037036.us-central1.run.app/api/update";

const url = async (system: string) =>
  (await (await fetch(`${api}/${system}/stable/latest`)).json()).url.replaceAll(
    " ",
    "%20",
  );

export default async () => {
  const [x86_64, aarch64] = await Promise.all([
    url("linux-x64"),
    url("linux-arm64"),
  ]);
  const version = /stable\/([\d.]+)-/.exec(x86_64)![1];

  return fetchurl({
    version,
    urls: {
      "x86_64-linux": { name: "antigravity-ide.tar.gz", url: x86_64 },
      "aarch64-linux": { name: "antigravity-ide.tar.gz", url: aarch64 },
    },
  });
};
