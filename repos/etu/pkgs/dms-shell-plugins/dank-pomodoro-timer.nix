{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-pomodoro-timer";
  version = "0-unstable-2026-10-05";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dms-plugins";
    rev = "a8a508bc371e7c3f2c7862d8840b88cf5c63978f";
    hash = "sha256-3nHfkGzmmq8JpN7bmO8Z5zIumvx8dzwS1GtQ6V0XgMg=";
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
