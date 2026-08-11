/*
FIXME pkg-config is required
checking for pkg-config... no
...
./configure: line 4027: --exists: command not found
*/

{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, zlib
}:

stdenv.mkDerivation rec {
  pname = "pdfio";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "michaelrsweet";
    repo = "pdfio";
    rev = "v${version}";
    hash = "sha256-0r8wSc5vrwJniOpTEyy+Nsyuo6UhfIB3+j10I2ELNcQ=";
  };

  nativeBuildInputs = [
    # fix: ./configure: line 4027: --exists: command not found
    pkg-config
  ];

  buildInputs = [
    zlib
  ];

  meta = with lib; {
    description = "PDFio is a simple C library for reading and writing PDF files";
    homepage = "https://github.com/michaelrsweet/pdfio";
    changelog = "https://github.com/michaelrsweet/pdfio/blob/${src.rev}/CHANGES.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
