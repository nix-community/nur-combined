{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  pname = "blocks";
  version = "0-unstable-2024-08-07";
  src = fetchFromGitHub {
    owner = "dan-german";
    repo = "blocks";
    rev = "fae783735daa8cb1a0b8158508ccede4292639ae";
    hash = "sha256-oqBmu3xm2RadkQfoRVLvqTj6b/yd+yagAeVMDrRRW5k=";
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
    description = "User friendly cross platform modular synth";
    homepage = "https://www.soonth.com/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "blocks";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
