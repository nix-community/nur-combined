import { github } from "nix-repin";

export default github.release({
  assets: {
    "aarch64-linux": "magpie-linux-arm64",
    "x86_64-linux": "magpie-linux-amd64",
  },
  repository: "yetone/magpie-releases",
  stripPrefix: "v",
});
