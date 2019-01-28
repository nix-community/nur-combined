{ stdenv, lib, buildGoPackage, fetchgit }:

buildGoPackage rec {
  name = "go-containerregistry-unstable-${version}";
  version = "2019-01-16";
  rev = "efb7e1b888e142e2c66af20fd44e76a939b2cc3e";

  goPackagePath = "github.com/google/go-containerregistry";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/google/go-containerregistry";
    sha256 = "1z0w07vaglk40kfym7a5kns8ypdd8hmjp5idwinvj0qiid7syx0i";
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
