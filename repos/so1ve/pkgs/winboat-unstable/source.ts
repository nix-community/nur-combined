import { bun, defineSource, github, go } from "nix-repin";

export default defineSource(
  github.branch({
    branch: "main",
    repository: "TibixDev/winboat",
  }),
  bun.lock(),
  go.lock({ attribute: "guest-server.goModules" }),
);
