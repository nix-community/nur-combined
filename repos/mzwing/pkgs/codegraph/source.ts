import { defineSource, github, npm } from "nix-repin";
import { crate2nix } from "../../internal/sources.ts";

export default defineSource(
  github.tag({
    repository: "colbymchenry/codegraph",
    tagPattern: "v[0-9]+\\.[0-9]+\\.[0-9]+",
    stripPrefix: "v",
  }),
  crate2nix({ manifest: "codegraph-kernel/Cargo.toml" }),
  npm.lock("package-lock.json"),
);
