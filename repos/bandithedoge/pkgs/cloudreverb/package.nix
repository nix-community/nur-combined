{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  pname = "cloudreverb";
  version = "0.5-unstable-2026-04-13";
  src = fetchFromGitHub {
    owner = "xunil-cloud";
    repo = "CloudReverb";
    rev = "92804eda8439d058a018dad606ebd1c403c37b90";
    hash = "sha256-erpJlS9VYvYyqYyKjyDuob7Jup+zLuj93j+BRAjPtl4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ juceCmakeHook ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "algorithmic reverb plugin based on CloudSeed";
    homepage = "https://github.com/xunil-cloud/CloudReverb";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "CloudReverb";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
