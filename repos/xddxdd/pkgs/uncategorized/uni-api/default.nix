{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-09-21";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "b920f29a9354331d05589c27eb5c272757c786ed";
    hash = "sha256-rndz5B/qWz4IVtJZR30zqqCFhmHBdTJWPmoNsl7SI2g=";
  };
  cargoRoot = "rust/uni-api-native";
  buildAndTestSubdir = "rust/uni-api-native";

  cargoHash = "sha256-FGuD4K12QEnAt7yugRzMfrbEtEl6uqV/3nf8VGvtrgc=";

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
