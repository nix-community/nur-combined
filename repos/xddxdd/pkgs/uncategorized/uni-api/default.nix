{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-29";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "55eec384c6ffda4973ae76d2426ea2652a03d560";
    hash = "sha256-Mw5c1UysJ3BF1fSXE3a1Ly8F8fAAie2MeFNQW/kGzXM=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-YUZRlJJT+jFTNuihkhAzZd05dwJJ/vd/0ulZn9w9fNQ=";

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
