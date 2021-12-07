{ lib, stdenv, fetchFromSourcehut, qbe }:

stdenv.mkDerivation rec {
  pname = "cproc";
  version = "2021-12-06";

  src = fetchFromSourcehut {
    owner = "~mcf";
    repo = pname;
    rev = "aefb830ede6316f5fcf4c3c48b79a661c66c9f2e";
    hash = "sha256-yxVW54uodYj1tRI7xaSFztParRxTfkLLMwqCDvqGYew=";
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
