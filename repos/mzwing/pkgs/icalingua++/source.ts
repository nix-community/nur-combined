import { github } from "nix-repin";

export default github.tag({
  repository: "Icalingua-plus-plus/Icalingua-plus-plus",
  tagPattern: "v[0-9]+\\.[0-9]+\\.[0-9]+",
  stripPrefix: "v",
});
