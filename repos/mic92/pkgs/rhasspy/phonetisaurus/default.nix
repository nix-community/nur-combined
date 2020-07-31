{ stdenv
, fetchFromGitHub
, openfst
, pkg-config
, python3 }:

stdenv.mkDerivation rec {
  pname = "phonetisaurus";
  version = "2020-07-09";

  src = fetchFromGitHub {
    owner = "AdolfVonKleist";
    repo = pname;
    rev = "d295f5f746717a697aceb07321b686b9d4130437";
    sha256 = "0sfi7mcs338r39c6mp183rh359wa9ih96s3zl2m7gkhgqgqxl13h";
  };

  patches = [
    ./0001-fix-compatiblity-with-openfst-1.7.7.patch
    ./0002-fix-compilation-with-openfst-1.7.9.patch
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
