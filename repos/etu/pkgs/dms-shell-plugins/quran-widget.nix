{
  lib,
  stdenvNoCC,
  fetchFromCodeberg,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-quran-widget";
  version = "0-unstable-2026-05-11";

  src = fetchFromCodeberg {
    owner = "MezoAhmedII";
    repo = "quranWidget";
    rev = "fb7485ec8458e0a3d2d257ff1b98fccd103cda4f";
    hash = "sha256-2Lkwo0KmPxnyYGdj/OsvJq4+hGcYOKJWG+E3TqUoZ68=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell desktop widget that shows a random Quranic Ayah";
    homepage = "https://codeberg.org/MezoAhmedII/quranWidget";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
