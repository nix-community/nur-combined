{
  lib, buildNpmPackage, fetchFromGitHub,
  cmake, autoconf271, automake, libtool, perl, pkg-config
}:
let
  pname = "aws-lambda-ric-nodejs";
  version = "3.2.0";
  hash = "sha256-b0HoDW1aSiYEnBfX42vsO9qQoPdwV8en6165ABpAuNA=";
  npmDepsHash = "sha256-XyHystDd+oxwhuNr5jpcqeVdMoEMUiSkvNF9P0M29Hs=";
in
buildNpmPackage {
  inherit pname version npmDepsHash;

  nativeBuildInputs = [
    cmake
    automake
    autoconf271
    libtool
    perl
    pkg-config
  ];

  src = fetchFromGitHub {
    inherit hash;
    owner = "aws";
    repo = "aws-lambda-nodejs-runtime-interface-client";
    rev = "v${version}";
  };

  dontUseCmakeConfigure = true;

  meta = {
    description = "AWS Lambda NodeJS Runtime Interface Client";
    homepage = "https://github.com/aws/aws-lambda-nodejs-runtime-interface-client";
    license = lib.licenses.mit;
    mainProgram = "aws-lambda-ric";
  };
}
