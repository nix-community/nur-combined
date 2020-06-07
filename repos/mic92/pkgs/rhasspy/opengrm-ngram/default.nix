{ stdenv, autoreconfHook, fetchurl, openfst }:

stdenv.mkDerivation rec {
  pname = "opengrm-ngram";
  version = "1.3.10";

  src = fetchurl {
    url = "http://www.openfst.org/twiki/pub/GRM/NGramDownload/ngram-${version}.tar.gz";
    sha256 = "1409f2mfy7sywqqqld6lm1hn3vs2p1ida5wirvmnhsbrjg10qhq5";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    openfst
  ];

  meta = with stdenv.lib; {
    description = "Library to make and modify n-gram language models encoded as weighted finite-state transducers";
    homepage = "http://www.openfst.org/twiki/bin/view/GRM/NGramLibrary";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
