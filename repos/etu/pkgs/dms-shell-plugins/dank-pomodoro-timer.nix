{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-pomodoro-timer";
  version = "0-unstable-2026-10-23";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dms-plugins";
    rev = "4b5adf9a1d6c09f93831ebd99b447ad8cae0d6a2";
    hash = "sha256-UX70fzgHTAZ4ULUvlRVCSP6WG+4EdHAut6jc5IUsj5Q=";
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
