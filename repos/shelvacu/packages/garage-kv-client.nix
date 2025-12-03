{ rustPlatform, garage_2 }:
rustPlatform.buildRustPackage {
  pname = "garage-kv-client";
  version = "0.0.4";

  inherit (garage_2) src cargoHash cargoPatches;

  buildAndTestSubdir = "src/k2v-client";
}
