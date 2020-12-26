{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "sfeed";
  version = "0.9.20";

  src = fetchgit {
    url = "git://git.codemadness.org/sfeed";
    rev = "${version}";
    sha256 = "17bs31wns71fx7s06rdzqkghkgv86r9d9i3814rznyzi9484c7aq";
  };

  patchPhase = ''
    sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" Makefile
  '';

  meta = {
    homepage = "https://codemadness.org/sfeed-simple-feed-parser.html";
    description = "Simple RSS and Atom parser";
    license = stdenv.lib.licenses.isc;
    maintainers = [ stdenv.lib.maintainers.noneucat ];
    platforms = stdenv.lib.platforms.all; 
  };
}