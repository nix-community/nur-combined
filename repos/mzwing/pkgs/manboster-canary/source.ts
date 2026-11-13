import { defineSource, github } from "nix-repin";
import { gomod2nix } from "../../internal/sources.ts";

export default defineSource(
  github.branch({
    repository: "manboster/manboster",
    branch: "dev",
    // Hold at 3aac0adc: the next commit, 5675a7c, fails to compile; remove once dev builds again
    before: "2026-09-26T16:45:00Z",
  }),
  gomod2nix(),
);
