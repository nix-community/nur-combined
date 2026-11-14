import { defineSource, github, go, pnpm } from "nix-repin";

export default defineSource(
  github.release({
    repository: "pocket-id/pocket-id",
    tagPattern: "v2\\.[0-9]+\\.[0-9]+",
    stripPrefix: "v",
  }),
  pnpm.lock("frontend.pnpmDeps"),
  go.lock(),
);
