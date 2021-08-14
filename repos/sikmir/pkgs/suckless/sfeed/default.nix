{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "sfeed";
  version = "1.0";

  src = fetchgit {
    url = "git://git.codemadness.org/${pname}";
    rev = version;
    sha256 = "sha256-pLKWq4KIiT6X37EUIOw5SBb1KWopnFcDO+iE++Uie5s=";
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
