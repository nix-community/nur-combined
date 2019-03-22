{ stdenv, lib, buildGoPackage, fetchgit }:

buildGoPackage rec {
  name = "go-containerregistry-unstable-${version}";
  version = "2019-03-10";
  rev = "8c1640add99804503b4126abc718931a4d93c31a";

  goPackagePath = "github.com/google/go-containerregistry";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/google/go-containerregistry";
    sha256 = "0xnwqhawgignd3a6lw5f4qnw9mpfr50b8pa5sgnviszcqk7f15fy";
  };

  goDeps = ./deps.nix;
  subPackages = [
    "cmd/crane" "cmd/gcrane"
  ];

  meta = {
    description = "Go library and CLIs for working with container registries";
    homepage = https://github.com/google/go-containerregistry;
    license = lib.licenses.asl20;
  };
}
