{ lib
, stdenv
, fetchgit
, libtool
, automake
, autoconf
, intltool
, pkg-config
, libxml2
, libxslt
, docbook_xml_dtd_412 
, docbook_xsl
, wrapGAppsHook
, glib
, libX11
, gtk2-x11
, polkit
, vala
}:
let
  version = "0.5.5";
in
stdenv.mkDerivation {

  pname = "lxsession";
  inherit version;

  src = fetchgit {
    url = "git://git.lxde.org/git/lxde/lxsession";
    rev = version;
    sha256 = "17sqsx57ymrimm5jfmcyrp7b0nzi41bcvpxsqckmwbhl19g6c17d";
  };

  patches = [ ./xmlcatalog_patch.patch ];

  nativeBuildInputs = [
    vala
    glib
    docbook_xml_dtd_412
    docbook_xsl
    libxslt
    libxml2
    pkg-config
    intltool
    autoconf
    automake
    libtool
  ];
  buildInputs = [ polkit gtk2-x11 libX11 ];
  
  configureFlags = [
    "--enable-man"
    "--disable-buildin-clipboard"
    "--disable-buildin-polkit"
    "--with-xml-catalog=${docbook_xml_dtd_412}/xml/dtd/docbook/catalog.xml"
  ];

  preConfigure = "./autogen.sh";

  meta = with lib; {
    description = "Classic LXDE session manager";
    license = licenses.gpl2;
    homepage = "http://git.lxde.org/gitweb/?p=lxde/lxsession.git";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
