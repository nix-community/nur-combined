{
  lib,
  stdenvNoCC,
  fetchFromCodeberg,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-media-frame";
  version = "0-unstable-2026-05-07";

  src = fetchFromCodeberg {
    owner = "claymorwan";
    repo = "dms-plugins";
    rev = "c0de20519e991a0cbf826da5618bc59127a2d4da";
    hash = "sha256-mvZUHB6ZvqrPqOWd5FQgXSzqV68mlnGB669zJRHpu5c=";
  };

  sourceRoot = "source/mediaFrame";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell desktop plugin that displays a picture on your desktop";
    homepage = "https://codeberg.org/claymorwan/dms-plugins";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
