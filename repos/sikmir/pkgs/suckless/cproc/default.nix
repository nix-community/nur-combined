{ lib, stdenv, fetchFromSourcehut, qbe }:

stdenv.mkDerivation rec {
  pname = "cproc";
  version = "2022-01-19";

  src = fetchFromSourcehut {
    owner = "~mcf";
    repo = pname;
    rev = "51e61fa5fa3de8cabc2191a5c6ac4d18aaaaf049";
    hash = "sha256-0qJyCm3NU7T/NPHqNyWdN+7DwVcl2OwJCBBeJ17H3rs=";
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
