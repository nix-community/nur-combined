{ pkgs, stdenv, ... }:

stdenv.mkDerivation {
  pname = "gotham-fonts";
  version = "2011-2016";
  src = ./.;

  installPhase = ''
    mkdir -p $out/share/fonts/opentype/
    cp -r *.otf $out/share/fonts/opentype/
  '';

  meta = with pkgs.lib; {
    description = "Gotham font family - a geometric sans-serif typeface";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
