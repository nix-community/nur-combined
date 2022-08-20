{ lib, stdenv, fetchFromSourcehut, qbe }:

stdenv.mkDerivation rec {
  pname = "cproc";
  version = "2022-08-05";

  src = fetchFromSourcehut {
    owner = "~mcf";
    repo = "cproc";
    rev = "6fabc79d81de56b6c1cdcc2242933fd792e2ddf9";
    hash = "sha256-u00tGBBdLSQevge1xjOmgZGdlnfjpXFIQuqIzqbg858=";
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
