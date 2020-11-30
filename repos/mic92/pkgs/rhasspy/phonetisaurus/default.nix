{ stdenv
, fetchFromGitHub
, openfst
, pkg-config
, python3
}:

stdenv.mkDerivation rec {
  pname = "phonetisaurus";
  version = "2020-06-31";

  src = fetchFromGitHub {
    owner = "AdolfVonKleist";
    repo = pname;
    rev = "2831870697de5b4fbcb56a6e1b975e0e1ea10deb";
    sha256 = "sha256-O2aPR1W1rvhFUKVD4z7P90Px5atWJpsghg5Q8H/RKKw=";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openfst
    python3
  ];

  meta = with stdenv.lib; {
    homepage = "Framework for Grapheme-to-phoneme models for speech recognition using the OpenFst framework";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
