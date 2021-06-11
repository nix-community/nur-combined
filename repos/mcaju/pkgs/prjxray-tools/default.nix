{ stdenv
, lib
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname   = "prjxray-tools";
  version = "0.1-2928-gda7bf6a0";

  src = fetchFromGitHub {
    owner  = "SymbiFlow";
    repo   = "prjxray";
    fetchSubmodules = true;
    rev    = "da7bf6a0789c9c573cb3f43307cbd99d570ebcde";
    sha256 = "17i5xf61q4j4g3k0iwl6phkpn5wqzcv6xz2j9rr3fd192bmsqwxn";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Documenting the Xilinx 7-series bit-stream format";
    homepage    = "https://github.com/SymbiFlow/prjxray";
    license     = licenses.isc;
    platforms   = platforms.all;
  };
}
