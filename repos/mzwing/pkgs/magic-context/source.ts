import { github } from "nix-repin";

export default github.tag({
  repository: "cortexkit/magic-context",
  // The pattern excludes the dashboard's own `dashboard-v*` tag series.
  tagPattern: "v[0-9]+\\.[0-9]+\\.[0-9]+",
  stripPrefix: "v",
});
