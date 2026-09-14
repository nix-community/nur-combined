{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dms-desktop-countdown";
  version = "1.0.1-unstable-2026-05-31";

  src = fetchFromGitHub {
    owner = "nfoert";
    repo = "dms-desktop-countdown";
    rev = "cd0c9fb65aad4b8a72502369a60e2a6fbeacba4e";
    hash = "sha256-/lKL+ABOlNLrJ4eWjRcgzq442Go4UenM1DUGPqV1Swk=";
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
