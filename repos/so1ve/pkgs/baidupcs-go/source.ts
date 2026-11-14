import { defineSource, github, go } from "nix-repin";

export default defineSource(
  github.release({
    repository: "qjfoidnh/BaiduPCS-Go",
    stripPrefix: "v",
  }),
  go.lock(),
);
