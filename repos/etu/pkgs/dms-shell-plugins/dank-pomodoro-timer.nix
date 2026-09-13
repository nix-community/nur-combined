{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-pomodoro-timer";
  version = "0-unstable-2026-09-07";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dms-plugins";
    rev = "6fc7f25bfb24f93b6488fb8a36ed67b5f242abdb";
    hash = "sha256-KGpNgxN/zXiMjLLm4zLX+Wgnj1vx8bGGd6WwGBWo7Ds=";
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
