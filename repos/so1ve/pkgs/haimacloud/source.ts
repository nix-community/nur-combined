import { github } from "nix-repin";

export default github.release({
  assets: {
    "aarch64-linux": "com\\.haimacloud\\.otohime_.*_arm64\\.deb",
    "x86_64-linux": "com\\.haimacloud\\.otohime_.*_amd64\\.deb",
  },
  repository: "kota-rina3/hokeshi",
  stripPrefix: "haimacloud",
  tagPattern: "haimacloud[0-9].*",
});
