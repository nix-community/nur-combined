{ lib, stdenv, fetchFromSourcehut, qbe }:

stdenv.mkDerivation (finalAttrs: {
  pname = "cproc";
  version = "2022-12-14";

  src = fetchFromSourcehut {
    owner = "~mcf";
    repo = "cproc";
    rev = "0985a7893a4b5de63a67ebab445892d9fffe275b";
    hash = "sha256-7wZw4YxMHTC7fDxl8JE1cfSEPXw30YbvwoV1YH/PHPw=";
  };

  buildInputs = [ qbe ];

  doCheck = true;

  meta = with lib; {
    description = "C11 compiler using QBE as a backend";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
