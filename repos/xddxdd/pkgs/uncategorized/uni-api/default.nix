{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-12";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "2a7196abee37d9ddb01184d5bdde85e840335fad";
    hash = "sha256-I/avtbxGdhXl65UNiMBMr7jhTW8xbCc58QmSDg1lfkk=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-ki5mr1+vofKQ2x1PhCGxr3sORTxhI345r1FO68zlkEg=";

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
