{ stdenv, lib, buildGoPackage, fetchgit }:

buildGoPackage rec {
  name = "go-containerregistry-unstable-${version}";
  version = "2019-01-09";
  rev = "caf7c6e366716b04fb9876ca00d55dedb72e4f23";

  goPackagePath = "github.com/google/go-containerregistry";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/google/go-containerregistry";
    sha256 = "0cwrapybl6psxfl6xa8f1nn1l2x6wzz2y9b5z96gfxp2dlrsknjk";
  };

  goDeps = ./deps.nix;
  subPackages = [
    "cmd/crane" "cmd/gcrane" "cmd/ko"
  ];

  meta = {
    description = "Go library and CLIs for working with container registries";
    homepage = https://github.com/google/go-containerregistry;
    license = lib.licenses.asl20;
  };
}
