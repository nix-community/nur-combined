{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dms-desktop-countdown";
  version = "1.0.2-unstable-2026-10-21";

  src = fetchFromGitHub {
    owner = "nfoert";
    repo = "dms-desktop-countdown";
    rev = "d40c0b420f6ac32b30d1f7695dab904a654dcfcb";
    hash = "sha256-EtntBrZWzN2FBEpokLI8ekQcdqPXcaTVh101op2XINc=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell desktop widget for countdowns with progress, view options, and the ability to only count certain days of the week";
    homepage = "https://github.com/nfoert/dms-desktop-countdown";
    license = licenses.gpl3Only;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
