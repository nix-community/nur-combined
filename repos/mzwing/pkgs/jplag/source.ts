import { github } from "nix-repin";

export default github.release({
  repository: "jplag/JPlag",
  tagPattern: "v[0-9]+\\.[0-9]+\\.[0-9]+",
  stripPrefix: "v",
  assets: {
    default: "jplag-{version}-jar-with-dependencies\\.jar",
  },
});
