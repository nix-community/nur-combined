import { github } from "nix-repin";

export default github.release({
  assets: {
    "aarch64-linux":
      "flutter_rust_bridge_codegen-aarch64-unknown-linux-musl-v{version}.tgz",
    "x86_64-linux":
      "flutter_rust_bridge_codegen-x86_64-unknown-linux-musl-v{version}.tgz",
  },
  repository: "fzyzcjy/flutter_rust_bridge",
  stripPrefix: "v",
  includePrerelease: true,
});
