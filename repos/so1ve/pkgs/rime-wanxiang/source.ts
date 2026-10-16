import { github } from "nix-repin";

export default github.release({
  repository: "amzxyz/rime-wanxiang",
  stripPrefix: "v",
});
