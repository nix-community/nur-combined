{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "scroll";
  version = "0.1";

  src = fetchgit {
    url = "git://git.suckless.org/scroll";
    rev = version;
    sha256 = "13qbzpw68140zzdmfdqww23b4brviqdpqvr134gjh1kpmpa6rgbn";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Scrollbackbuffer program for st";
    homepage = "https://tools.suckless.org/scroll/";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
