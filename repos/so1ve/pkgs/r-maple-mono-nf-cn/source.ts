import { github } from "nix-repin";

export default github.release({
  assets: {
    default: "RMapleMono-NF-CN.zip",
  },
  repository: "so1ve/maple-font",
  stripPrefix: "v",
});
