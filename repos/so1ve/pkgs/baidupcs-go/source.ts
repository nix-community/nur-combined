import { github } from "nix-repin";

export default github.release({
  repository: "qjfoidnh/BaiduPCS-Go",
  stripPrefix: "v",
});
