{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-11-04";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "ee763b83d89bf8924aa81419d164cf9f1e8e3bd2";
    hash = "sha256-G7kueEo2gOsc+9Cwx9LbV/0x3VdNt68hYKtD9xx5FBE=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-7RXidtcneWKtCxrGqdDszVwJ9Y6Hy5YzG8dP0UxX7mU=";

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
