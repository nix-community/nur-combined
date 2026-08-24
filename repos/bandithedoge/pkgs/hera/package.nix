{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  pname = "hera";
  version = "0-unstable-2021-08-15";
  src = fetchFromGitHub {
    owner = "jpcima";
    repo = "Hera";
    rev = "f6fe5b900f4cf84809686466e0a37de5edf008fd";
    fetchSubmodules = true;
    sha256 = "sha256-eJNrAFvr8WfYOrndMZ80uK5q2fe3pGEbRMsEEE4XNEk=";
  };

  nativeBuildInputs = [ juceCmakeHook ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Juno 60 emulation synthesizer";
    homepage = "https://github.com/jpcima/Hera";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
