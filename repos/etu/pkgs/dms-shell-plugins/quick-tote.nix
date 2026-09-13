{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-quick-tote";
  version = "0-unstable-2026-09-08";

  src = fetchFromGitHub {
    owner = "JDKamalakar";
    repo = "DMS-Quick_Tote";
    rev = "5c32375e37da1246eec1bd8bcee3e1c85c14aeed";
    hash = "sha256-bbXQibpo8PPEBeoSgMQvq+sAKDmOG1rW+H303rWMaFw=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget for quick access to recent downloads, screenshots, and pinned files, ChromeOS Tote style";
    homepage = "https://github.com/JDKamalakar/DMS-Quick_Tote";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
