{ stdenv, fetchgit }:

stdenv.mkDerivation {
  pname = "quark";
  version = "unstable-2020-09-16";

  src = fetchgit {
    url = "git://git.suckless.org/quark";
    rev = "5d0221dd68c0d2b8796479d06b602be666d0f4c6";
    sha256 = "0glyg36b2mk5iip97h1wh9ybhsz6rqwqvjgyhshqqgiirplq9fva";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with stdenv.lib; {
    description = "Extremely small and simple HTTP GET/HEAD-only web server for static content";
    homepage = "http://tools.suckless.org/quark";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
  };
}
