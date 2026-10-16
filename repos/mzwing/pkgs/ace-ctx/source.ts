import { defineSource, github } from "nix-repin";
import { crate2nix } from "../../internal/sources.ts";

export default defineSource(
  github.tag({
    repository: "CodingOX/ace-ctx",
    tagPattern: "v[0-9]+\\.[0-9]+\\.[0-9]+",
    stripPrefix: "v",
  }),
  crate2nix(),
);
