{
  lib,
  stdenv,
  ...
}:

stdenv.mkDerivation {
  name = "menus";
  src = lib.cleanSource ./.;

  installPhase = ''
    mkdir -p $out/bin
    cp bin/menus $out/bin/sbar_menus
  '';

  meta = {
    platforms = lib.platforms.darwin;
  };
}
