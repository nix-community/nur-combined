import { defineSource, github } from "nix-repin";
import { gomod2nix } from "../../internal/sources.ts";

export default defineSource(
  github.tag({
    repository: "manboster/manboster",
    tagPattern: "v[0-9]+\\.[0-9]+\\.[0-9]+(-rc(\\.?[0-9]+)?)?",
    stripPrefix: "v",
  }),
  gomod2nix(),
);
