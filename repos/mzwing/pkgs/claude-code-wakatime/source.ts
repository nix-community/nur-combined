import { defineSource, github, npm } from "nix-repin";

export default defineSource(
  github.tag({
    repository: "wakatime/claude-code-wakatime",
    tagPattern: "v[0-9]+\\.[0-9]+\\.[0-9]+",
    stripPrefix: "v",
  }),
  npm.lock("package-lock.json"),
);
