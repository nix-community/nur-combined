{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  projucer,
}:
stdenv.mkDerivation {
  pname = "xen";
  version = "st3-unstable-2026-08-30";
  src = fetchFromGitHub {
    owner = "Mrugalla";
    repo = "Xen";
    rev = "5b89d89324ab46865e4fa1af23f401a61c0ae6c4";
    hash = "sha256-zY5ZQBo9MrYI/NR05mJwfIBQA65oMjlT5WEnc8HRjM0=";
  };

  nativeBuildInputs = [
    projucer
  ];

  jucerFile = "Xen.jucer";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "VSTi that transforms input MIDI to polyphonic xenharmonic MPE MIDI";
    homepage = "https://github.com/Mrugalla/Xen";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
