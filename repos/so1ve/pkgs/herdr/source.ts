import { github } from "nix-repin";

export default github.release({
  assets: {
    "aarch64-linux": "herdr-linux-aarch64",
    "x86_64-linux": "herdr-linux-x86_64",
  },
  repository: "herdrdev/herdr",
  stripPrefix: "v",
});
