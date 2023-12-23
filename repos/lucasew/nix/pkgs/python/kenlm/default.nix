{ buildPythonPackage
, fetchFromGitHub
, lib
, cmake
, boost
, eigen
, zlib
, bzip2
, lzma
}:

buildPythonPackage {
  pname = "kenlm";
  version = "unstable-2023-08-19";
  # format = "pyproject";

  src = fetchFromGitHub {
    owner = "kpu";
    repo = "kenlm";
    rev = "35f145839eca742f2402716d17542fd0546efc9d";
    hash = "sha256-uD3bMbWB3nBOyohcufDHDVYjleXYEJf1oCh/JQAX2/M=";
  };

  preBuild = ''
    cd ..
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [ boost eigen zlib bzip2 lzma ];

  meta = {
    description = "aster and Smaller Language Model Queries";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.lucasew ];
  };
}
