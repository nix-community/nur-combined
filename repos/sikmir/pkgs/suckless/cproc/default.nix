{ lib, stdenv, fetchFromSourcehut, qbe }:

stdenv.mkDerivation rec {
  pname = "cproc";
  version = "2021-10-25";

  src = fetchFromSourcehut {
    owner = "~mcf";
    repo = pname;
    rev = "e345d6fc4e3223e2d2655114c8829538276a0bb9";
    hash = "sha256-98xsikrGcaKdrIUcwgkHw8YJqbO1no6MvUOtlXQ3w54=";
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
