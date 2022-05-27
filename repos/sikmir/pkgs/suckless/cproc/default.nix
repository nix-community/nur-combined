{ lib, stdenv, fetchFromSourcehut, qbe }:

stdenv.mkDerivation rec {
  pname = "cproc";
  version = "unstable-2022-05-19";

  src = fetchFromSourcehut {
    owner = "~mcf";
    repo = pname;
    rev = "c88c649fc658a6acf4e03999268d6546b9dad87e";
    hash = "sha256-zqZJfSuwA61rWhT4g63R7+oeNlkIn4eL6B1y/R+Q7WQ=";
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
