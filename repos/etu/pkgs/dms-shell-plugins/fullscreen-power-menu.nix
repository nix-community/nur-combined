{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-fullscreen-power-menu";
  version = "0-unstable-2026-09-07";

  src = fetchFromGitHub {
    owner = "JDKamalakar";
    repo = "DMS-Fullscreen_Power_Menu";
    rev = "d6a184c979696ad6ae24e98579d7ca9ba7c9268b";
    hash = "sha256-SJ1ZZ2zfGg8xYx7GZmri4DCGE2LHLKKgbfSSv5HomFY=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "Material 3 inspired fullscreen DankMaterialShell power menu triggered via IPC";
    homepage = "https://github.com/JDKamalakar/DMS-Fullscreen_Power_Menu";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
