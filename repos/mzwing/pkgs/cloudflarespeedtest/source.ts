import { defineSource, github } from "nix-repin";
import { gomod2nix } from "../../internal/sources.ts";

export default defineSource(
  github.tag({
    repository: "XIU2/CloudflareSpeedTest",
    tagPattern: "v[0-9]+\\.[0-9]+\\.[0-9]+",
    stripPrefix: "v",
  }),
  gomod2nix(),
);
