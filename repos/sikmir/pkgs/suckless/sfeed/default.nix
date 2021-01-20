{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "sfeed";
  version = "0.9.20";

  src = fetchgit {
    url = "git://git.codemadness.org/sfeed";
    rev = version;
    sha256 = "17bs31wns71fx7s06rdzqkghkgv86r9d9i3814rznyzi9484c7aq";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with stdenv.lib; {
    description = "RSS and Atom parser";
    homepage = "https://git.codemadness.org/sfeed/";
    license = licenses.isc;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
