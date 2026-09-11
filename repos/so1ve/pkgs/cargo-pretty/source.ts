import { github } from "nix-repin";

export default github.release({
  assets: {
    "x86_64-linux": "cargo-pretty-x86_64-unknown-linux-gnu.tar.gz",
  },
  repository: "romancitodev/cargo-pretty",
  stripPrefix: "v",
});
