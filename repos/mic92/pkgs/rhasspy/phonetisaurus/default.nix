{ stdenv
, fetchFromGitHub
, openfst
, pkg-config
, python3 }:

stdenv.mkDerivation rec {
  pname = "phonetisaurus";
  version = "2020-05-13";

  src = fetchFromGitHub {
    owner = "AdolfVonKleist";
    repo = pname;
    rev = "894fd9e416f7cf01db7b4668c6e15811beaae4cb";
    sha256 = "1qczr0mda83yvk8zhajd5b7clar85qgb4fn139ngwldn2b33v0kj";
  };

  patches = [
    ./0001-compile-fixes-for-openfst-1.7.7.patch
  ];

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
