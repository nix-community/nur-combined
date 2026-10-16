import { defineSource, github } from "nix-repin";
import { gomod2nix } from "../../internal/sources.ts";

export default defineSource(
  github.branch({
    repository: "manboster/manboster",
    branch: "dev",
  }),
  gomod2nix(),
);
