import { marketplace } from "nix-repin";

export default marketplace.extension({
  publisher: "JetBrains",
  name: "kotlin-server",
  platforms: {
    "x86_64-linux": "linux-x64",
    "aarch64-linux": "linux-arm64",
  },
});
