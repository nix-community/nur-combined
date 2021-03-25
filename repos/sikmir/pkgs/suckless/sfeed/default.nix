{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "sfeed";
  version = "0.9.22";

  src = fetchgit {
    url = "git://git.codemadness.org/sfeed";
    rev = version;
    sha256 = "1wgsghc07k5mndfz1bzk2ziiw63x5zg5d5qxnxqg8r74f6lj9g9l";
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
