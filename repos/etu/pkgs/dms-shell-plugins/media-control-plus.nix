{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-media-control-plus";
  version = "0-unstable-2026-07-31";

  src = fetchFromGitHub {
    owner = "Dadangdut33";
    repo = "dms-plugins";
    rev = "63fe6b87c497f1f7c2ea61432716817db1c5c3a4";
    hash = "sha256-/iIqBej8dFwOQpvO9PXFvnDwZMSA7IykzaQjl5xoJUs=";
  };

  sourceRoot = "source/MediaControlPlus";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell customized version of the DMS media widget with extended features, mainly focused on improving vertical bar support";
    homepage = "https://github.com/Dadangdut33/dms-plugins";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
