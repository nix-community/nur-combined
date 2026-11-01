{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-11-01";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "4865d284406230ad60eec3c33ae243c9077d1328";
    hash = "sha256-/W+EOXTIF7cexLKUA+81YFzyOWxA8v88AKXcuogKmY4=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-m0TM7HLRnD+2Zyy0RoxhTMPlDktTenOrv49czPfZ+Dw=";

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
