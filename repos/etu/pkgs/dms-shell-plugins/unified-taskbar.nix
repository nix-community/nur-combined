{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-unified-taskbar";
  version = "0-unstable-2026-09-07";

  src = fetchFromGitHub {
    owner = "jslandau";
    repo = "dms-unified-taskbar";
    rev = "eba5b385cfbbda85587fa0a4feefe293563617ff";
    hash = "sha256-gOLipzxMKrGqP0DZdWzEszGzgwtz2FJde+nHiU8CwZo=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell DankBar widget showing running apps grouped by workspace with per-workspace pills";
    homepage = "https://github.com/jslandau/dms-unified-taskbar";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
