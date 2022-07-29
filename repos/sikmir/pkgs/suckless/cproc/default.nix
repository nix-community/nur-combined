{ lib, stdenv, fetchFromSourcehut, qbe }:

stdenv.mkDerivation rec {
  pname = "cproc";
  version = "2022-07-12";

  src = fetchFromSourcehut {
    owner = "~mcf";
    repo = "cproc";
    rev = "83116cabc84ff3478ea19be38e8891d83a60acd6";
    hash = "sha256-xQ7tms9b11+qmLpS2k+LudTuwxIvui1aNs9PoTliumo=";
  };

  buildInputs = [ qbe ];

  doCheck = true;

  meta = with lib; {
    description = "C11 compiler using QBE as a backend";
    inherit (src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
