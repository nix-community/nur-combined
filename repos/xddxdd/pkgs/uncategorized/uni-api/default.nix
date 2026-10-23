{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-22";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "8429cbf951423cebdd15ffb191c53945e4817378";
    hash = "sha256-bVU6oKA+xcd9eZu+9mqHlP28iEPsV68k4nu7M264Yk0=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-HFexAdQCFE3+tM8ABxaknr0Wo4gXRmcwcs8qDiaYqS0=";

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
