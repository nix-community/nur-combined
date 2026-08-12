import { github } from "nix-repin";

export default github.release({
  assets: {
    "aarch64-linux": "ABDownloadManager_{version}_linux_arm64.tar.gz",
    "x86_64-linux": "ABDownloadManager_{version}_linux_x64.tar.gz",
  },
  repository: "amir1376/ab-download-manager",
  stripPrefix: "v",
});
