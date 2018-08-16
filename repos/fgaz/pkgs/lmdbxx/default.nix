{ stdenv, fetchFromGitHub, lmdb }:

stdenv.mkDerivation rec {
  name = "lmdbxx-${version}";
  version = "0.9.14.0";
  src = fetchFromGitHub {
    owner = "bendiken";
    repo = "lmdbxx";
    rev = "${version}";
    sha256 = "1jmb9wg2iqag6ps3z71bh72ymbcjrb6clwlkgrqf1sy80qwvlsn6";
  };
  propagatedBuildInputs = [ lmdb ];
  buildPhase = "make PREFIX=$out";
  installPhase = "make install PREFIX=$out";
}
