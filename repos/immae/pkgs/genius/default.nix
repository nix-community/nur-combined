{ stdenv, fetchurl, mpfr, glib, hicolor-icon-theme, gtk2, intltool, gnome-doc-utils, python3, gnome2, autoconf, automake, libtool, ncurses, readline, pkg-config, }:
stdenv.mkDerivation rec {
  name = "genius-${version}";
  version = "1.0.24";
  src = fetchurl {
    url = "https://download.gnome.org/sources/genius/1.0/${name}.tar.xz";
    sha256 = "772f95f6ae4716d39bb180cd50e8b6b9b074107bee0cd083b825e1e6e55916b6";
  };
  buildInputs = [
    mpfr glib hicolor-icon-theme gtk2 intltool gnome-doc-utils python3 gnome2.gtksourceview
    autoconf automake libtool ncurses readline pkg-config
  ];
  preConfigure = ''
    autoreconf -fi
    '';
  preBuild = ''
    sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
    '';
}
