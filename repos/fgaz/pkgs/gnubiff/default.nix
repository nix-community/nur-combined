{ stdenv, fetchurl, gtk3, popt, pkgconfig, gamin, intltool }:
stdenv.mkDerivation rec {
  name = "gnubiff-${version}";
  version = "2.2.17";
  src = fetchurl {
    url = "http://prdownloads.sourceforge.net/gnubiff/gnubiff-${version}.tar.gz";
    sha256 = "0b7vjd9bqp1j757x9y1w5f8xlajb1s0wrg524ydlngj93l1sn5p6";
  };
  buildInputs = [ gtk3 popt pkgconfig gamin intltool ];
  configureFlags = [ "--disable-gnome" ]; # with gnome enabled needs libpanel-applet. i will package that sooner or later
}

