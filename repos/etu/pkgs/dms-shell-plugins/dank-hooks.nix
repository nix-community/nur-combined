{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-hooks";
  version = "0-unstable-2026-10-23";

  src = fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "dms-plugins";
    rev = "4b5adf9a1d6c09f93831ebd99b447ad8cae0d6a2";
    hash = "sha256-UX70fzgHTAZ4ULUvlRVCSP6WG+4EdHAut6jc5IUsj5Q=";
  };

  sourceRoot = "source/DankHooks";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell daemon plugin to execute custom scripts on system events like wallpaper changes, theme updates, and battery level changes";
    homepage = "https://github.com/AvengeMedia/dms-plugins";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
