import { defineSource, fetchurl } from "nix-repin";

interface AurResponse {
  resultcount: number;
  results: Array<{
    Version: string;
  }>;
}

export default defineSource(async () => {
  const response = await fetch(
    "https://aur.archlinux.org/rpc/v5/info/baidunetdisk-bin",
  );

  const payload = await response.json() as AurResponse;

  const version = payload.results[0].Version.replace(/-[^-]+$/, "");

  return fetchurl({
    urls: {
      default:
        `https://pkg-ant.baidu.com/issue/netdisk/LinuxGuanjia/${version}/baidunetdisk_${version}_amd64.deb`,
    },
    version,
  });
});
