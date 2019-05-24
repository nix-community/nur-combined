{ stdenv, fetchurl, expat, openssl, autoconf, ncurses }:
stdenv.mkDerivation rec {
  name = "boinctui-${version}";
  version = "2.5.0";
  src = fetchurl {
    url = "http://sourceforge.net/projects/boinctui/files/boinctui_${version}.tar.gz";
    sha256 = "16zxp8r4z6pllacdacg681y56cg2phnn3pm5gwszbsi93cix2g8p";
  };

  configureFlags = [ "--without-gnutls" ];
  preConfigure = ''
    autoconf
    '';

  preBuild = ''
    sed -i -e 's/"HOME"/"XDG_CONFIG_HOME"/' src/cfg.cpp
    sed -i -e 's@\.boinctui\.cfg@boinctui/boinctui.cfg@' src/mainprog.cpp
    '';
  buildInputs = [ expat openssl autoconf ncurses ];
}
