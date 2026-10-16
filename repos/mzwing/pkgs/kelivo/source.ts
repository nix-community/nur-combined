import { defineSource, github, pubspec } from "nix-repin";

export default defineSource(
  github.tag({
    repository: "Chevey339/kelivo",
    tagPattern: "v[0-9]+\\.[0-9]+\\.[0-9]+",
    stripPrefix: "v",
  }),
  pubspec.lock({ flutter: "flutter347" }),
);
