import { github } from "nix-repin";

export default github.release({
  assets: {
    default: "rime-frost-schemas\\.zip",
  },
  repository: "gaboolic/rime-frost",
});
