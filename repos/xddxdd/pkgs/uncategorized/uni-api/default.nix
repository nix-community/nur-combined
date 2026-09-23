{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-09-23";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "3231d445687643dbfbf3f5387984a721dc5c266e";
    hash = "sha256-PYAjU7aBEb+Sd7FmpLva+1SOTzXDaf5HAZ1wAJ8td14=";
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
