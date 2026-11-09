import { bun, defineSource, github } from "nix-repin";

export default defineSource(
  github.branch({
    branch: "main",
    repository: "TibixDev/winboat",
    refresh: true,
  }),
  bun.lock(),
);
