import { github } from "nix-repin";

export default github.release({
  assets: {
    "x86_64-linux": "YesPlayMusic-{version}-linux-x64.tar.gz",
  },
  repository: "qier222/YesPlayMusic",
  stripPrefix: "v",
});
