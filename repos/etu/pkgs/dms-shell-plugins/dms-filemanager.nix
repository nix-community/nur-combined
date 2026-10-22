{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dms-filemanager";
  version = "1.0.6-unstable-2026-10-21";

  src = fetchFromGitHub {
    owner = "suruibin";
    repo = "dms-filemanager";
    rev = "eabc76e12af00443d32b7067d9855d2fcce1b61a";
    hash = "sha256-1nlgDZ3GQ6DoTX+eOvGU7QTwTEWFR/IoYKJrPDKOqDo=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell file manager plugin to browse, manage, and organize files on your desktop";
    homepage = "https://github.com/suruibin/dms-filemanager";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
