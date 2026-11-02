import { github } from "nix-repin";

export default github.tag({
  repository: "jarrodwatts/claude-hud",
  tagPattern: "v[0-9]+\\.[0-9]+\\.[0-9]+",
  stripPrefix: "v",
});
