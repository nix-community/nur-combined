{ stdenv, lib, fetchFromGitHub, buildGoPackage, jq }:
buildGoPackage rec {
  pname = "faq";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "jzelinskie";
    repo = "faq";
    rev = version;
    sha256 = "sha256:1766cpxcdjq1qj1iihp3s6y24czgw6lmdyrryzk3rhfbspcimcgh";
  };
  goDeps = ./deps.nix;
  goPackagePath = "github.com/jzelinskie/faq";
  buildInputs = [ jq ] ++ jq.buildInputs ; # need jq buildable at build faq time

  meta = {
    description = "format-agnostic jq";
    homepage = "https://github.com/jzelinskie/faq";
    license = lib.licenses.asl20;
  };
}
