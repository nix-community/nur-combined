{ stdenv, fetchgit }:

stdenv.mkDerivation {
  pname = "quark";
  version = "2020-11-01";

  src = fetchgit {
    url = "git://git.suckless.org/quark";
    rev = "7d26fc695d548b5a73305a97dce274a313e0f602";
    sha256 = "0308pfbyvbl5gfpl9lq62siz4kf7ki2zkk47p3b9r3j33dlpiszl";
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
