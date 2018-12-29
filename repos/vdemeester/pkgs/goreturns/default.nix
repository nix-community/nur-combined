{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "goreturns-unstable-${version}";
  version = "2018-10-28";
  rev = "538ac601451833c7c4449f8431d65d53c1c60e41";

  goPackagePath = "github.com/sqs/goreturns";

  src = fetchFromGitHub {
    inherit rev;
    owner = "sqs";
    repo = "goreturns";
    sha256 = "0gcplch8zmcgwl6xvcffxg50g3xnf60n7dlqxgn51179qcjr354p";
  };

  goDeps = ./deps.nix;

  meta = {
    description = "A gofmt/goimports-like tool for Go programmers that fills in Go return statements with zero values to match the func return types";
    homepage = https://github.com/sqs/goreturns;
    license = lib.licenses.asl20;
  };
}
