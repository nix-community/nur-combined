{ stdenv, fetchurl, pkgconfig, cairo, libxml2, libxslt, gtk3, pango
, gnome-doc-utils, intltool, which, itstool }:

stdenv.mkDerivation rec {
  name = "zenity-${version}";
  version = "3.28.0";

  src = fetchurl {
    url = "https://download.gnome.org/sources/zenity/${version}/zenity-${version}.tar.xz";
    sha256 = "5e588f12b987db30139b0283d39d19b0fd47cab87840cc112dfe61e592826df8";
  };

  NIX_LDFLAGS = stdenv.lib.optionalString stdenv.isDarwin "-lintl";
  preBuild = ''
    mkdir -p $out/include
  '';

  nativeBuildInputs = [ pkgconfig intltool gnome-doc-utils which ];
  buildInputs = [ gtk3 libxml2 libxslt itstool ];

  meta = with stdenv.lib; {
    platforms = platforms.unix;
};}
