{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-fullscreen-power-menu";
  version = "1.2.0-unstable-2026-10-10";

  src = fetchFromGitHub {
    owner = "JDKamalakar";
    repo = "DMS-Fullscreen_Power_Menu";
    rev = "3ec625d2e0105a063492249ef732a0ca91cf91b8";
    hash = "sha256-aKV0zwLCvRZdZdRfrbD6vjyFS6E7ckqmzOUy15oEwJ4=";
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
