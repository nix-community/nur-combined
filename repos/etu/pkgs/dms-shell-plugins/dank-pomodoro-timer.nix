{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-pomodoro-timer";
  version = "0-unstable-2026-09-15";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dms-plugins";
    rev = "bb90a1db7d540e64ae049c5906afba9b24baa865";
    hash = "sha256-NYmw2wCZYAKNU1xcodKMDXs5wwtAguOUNazRxcLjsUE=";
  };

  sourceRoot = "source/DankPomodoroTimer";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell productivity timer widget with 25-minute work sessions and breaks";
    homepage = "https://github.com/AvengeMedia/dms-plugins";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
