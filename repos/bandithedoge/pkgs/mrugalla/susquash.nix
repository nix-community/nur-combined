{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  projucer,
}:
stdenv.mkDerivation {
  pname = "susquash";
  version = "st-unstable-2026-03-23";
  src = fetchFromGitHub {
    owner = "Mrugalla";
    repo = "susquash";
    rev = "4e275b42510ec6325d9f548c5d82d7211281fcc0";
    hash = "sha256-6HtbB4q4ytweoOk47T05RQcbI4EcvTOFcf0oQUt1Q78=";
  };

  nativeBuildInputs = [
    projucer
  ];

  jucerFile = "susquash.jucer";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "plugin that crushes shit massively";
    homepage = "https://github.com/Mrugalla/susquash";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
