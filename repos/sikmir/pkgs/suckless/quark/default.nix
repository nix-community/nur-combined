{ stdenv, fetchgit, patches ? [] }:

stdenv.mkDerivation {
  pname = "quark";
  version = "2021-01-16";

  src = fetchgit {
    url = "git://git.suckless.org/quark";
    rev = "e5db41118f5c9bfc27338a803d6d4eebec05cc1b";
    sha256 = "1nvs2d8vwlkga2bc8964wfmk3810bcs9wy7m1nc00n1wjgh8wcsi";
  };

  inherit patches;

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with stdenv.lib; {
    description = "Extremely small and simple HTTP GET/HEAD-only web server for static content";
    homepage = "http://tools.suckless.org/quark";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
  };
}
