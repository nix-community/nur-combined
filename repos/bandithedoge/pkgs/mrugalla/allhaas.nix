{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  projucer,
}:
stdenv.mkDerivation {
  pname = "allhaas";
  version = "VST-unstable-2025-09-12";
  src = fetchFromGitHub {
    owner = "Mrugalla";
    repo = "ALLHaas";
    rev = "1c897e3ed25c37b6b64a093c42d2363d4b23189f";
    hash = "sha256-0YnO0QNiPYFdcw22dVbOyFZlwOLq1orWrEVF7kmk9lE=";
  };

  nativeBuildInputs = [
    projucer
  ];

  jucerFile = "ALLHaas.jucer";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Stereo widening tool that uses a lot of allpass filters";
    homepage = "https://github.com/Mrugalla/ALLHaas";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
