import { defineSource, github, go } from "nix-repin";

export default defineSource(
  github.tag({
    repository: "yetone/magpie",
    stripPrefix: "v",
    tagPattern: "v[0-9]+\\.[0-9]+\\.[0-9]+",
  }),
  go.lock(),
);
