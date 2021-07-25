{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "sfeed";
  version = "0.9.25";

  src = fetchgit {
    url = "git://git.codemadness.org/sfeed";
    rev = version;
    sha256 = "sha256-/3H86+a0EzIBVO9QVVqwOoJT9mHlXzlL/mraK9mfAvU=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "RSS and Atom parser";
    homepage = "https://git.codemadness.org/sfeed/";
    license = licenses.isc;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
