import { github } from "nix-repin";

export default github.release({
  assets: {
    "x86_64-linux": "YesPlayMusic-{version}.AppImage",
  },
  repository: "qier222/YesPlayMusic",
  stripPrefix: "v",
});
