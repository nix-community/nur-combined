{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  projucer,
}:
stdenv.mkDerivation {
  pname = "xen";
  version = "st3-unstable-2026-01-12";
  src = fetchFromGitHub {
    owner = "Mrugalla";
    repo = "Xen";
    rev = "4f15fc030d2687dd0c4ae499125e27bdec7e54bf";
    hash = "sha256-qyudHZf7GrhtS499KCij41uvfGVq00hQc3YXesw7SvI=";
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
