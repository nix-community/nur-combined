{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-09-24";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "c944b27ebea42785111b42da3d8f0420933a1fe8";
    hash = "sha256-licLypF00Baec3epF17CneXYk2HVpWkSCEGRDktwInM=";
  };
  cargoRoot = "rust/uni-api-native";
  buildAndTestSubdir = "rust/uni-api-native";

  cargoHash = "sha256-toCEv/PGau0zB4OjG/9Iu5BiloGfGbuDs3rbbyewuZc=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Unifies the management of LLM APIs across multiple backend services";
    homepage = "https://github.com/yym68686/uni-api";
    license = lib.licenses.unfree;
    mainProgram = "uni-api-front";
  };
})
