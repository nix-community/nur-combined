{ lib, stdenv, fetchFromGitHub, pcre, openssl }:

stdenv.mkDerivation rec {
  pname = "csvtools";
  version = "2019-08-03";

  src = fetchFromGitHub {
    owner = "DavyLandman";
    repo = "csvtools";
    rev = "efd3ef1c94c26c673e958ecb045056bfc2c7b4f3";
    hash = "sha256-hNEI5vQ3j6zyn31H2G+0xywdff7uaXi0kv2q4Hjiimg=";
  };

  buildInputs = [ pcre ];

  makeFlags = [ "prefix=$(out)" ];
  enableParallelBuilding = true;

  doCheck = true;
  checkInputs = [ openssl ];

  preCheck = "patchShebangs .";

  preInstall = "mkdir -p $out/bin";

  meta = with lib; {
    description = "GNU-alike tools for parsing RFC 4180 CSVs at high speed";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
