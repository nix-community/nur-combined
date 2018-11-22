{ stdenv, lib, buildGoPackage, fetchgit }:

buildGoPackage rec {
  name = "go-containerregistry-unstable-${version}";
  version = "2018-11-22";
  rev = "61e4aeff7593142b9b77936a476c38976a67e0db";

  goPackagePath = "github.com/google/go-containerregistry";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/google/go-containerregistry";
    sha256 = "1l9r4mbpdr23ncfhcpi1f44xrcp5s46j8nhsw9aanhm27mb1nag6";
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
