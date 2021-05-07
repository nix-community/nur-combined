{ lib, stdenv, fetchgit }:

stdenv.mkDerivation {
  pname = "quark";
  version = "2021-02-22";

  src = fetchgit {
    url = "git://git.suckless.org/quark";
    rev = "68b4f733b2755762e43df90f73db5a6ec8d14104";
    sha256 = "141v7x7p54443z6s0xm34c60qsz6lrbrvxlymf7fwxy7jz6bknr6";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Extremely small and simple HTTP GET/HEAD-only web server for static content";
    homepage = "http://tools.suckless.org/quark";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
