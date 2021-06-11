{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "sfeed";
  version = "0.9.24";

  src = fetchgit {
    url = "git://git.codemadness.org/sfeed";
    rev = version;
    sha256 = "sha256-nwvY79Xj/p7Z8npgq62RFOpG6Z8i7OsmLvQSrGD7LNA=";
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
