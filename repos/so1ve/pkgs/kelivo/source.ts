import { github } from "nix-repin";

export default github.release({
  assets: {
    "x86_64-linux": "Kelivo_linux_{version}+*.tar.gz",
  },
  includePrerelease: true,
  repository: "Chevey339/kelivo",
  stripPrefix: "v",
});
