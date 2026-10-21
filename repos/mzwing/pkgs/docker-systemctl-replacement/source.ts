import { github } from "nix-repin";

export default github.tag({
  repository: "gdraheim/docker-systemctl-replacement",
  tagPattern: "v[0-9]+\\.[0-9]+\\.[0-9]+",
  stripPrefix: "v",
});
