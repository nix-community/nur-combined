{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-11-09";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "a2aa6f2d73e9f90d317935fb95b2fb9f649803d9";
    hash = "sha256-zkRsmok7CLcNaiJZK3yN3bLLwMNnMBZWJR4znu7OuRA=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-enC2S7ezz6Mu7EeVZtU0Sm1C/XyIJgSvlJuXyV54Io0=";

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
