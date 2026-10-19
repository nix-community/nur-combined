{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-19";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "b4a803f118563ec2609581a3e10079f5e4c557dc";
    hash = "sha256-GukSm3r/l6gImrB88X7C7t2RNu0z32I67VcUVDO+AKQ=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-Hs40PDk7oXqbmI5dWt1/b09MfNdz5QO2TQ0wxbf6U60=";

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
