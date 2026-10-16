import { defineSource, github } from "nix-repin";
import { crate2nix } from "../../internal/sources.ts";

export default defineSource(
  github.tag({
    repository: "XDSEC/WebSocketReflectorX",
    tagPattern: "[0-9]+\\.[0-9]+\\.[0-9]+",
  }),
  crate2nix(),
);
