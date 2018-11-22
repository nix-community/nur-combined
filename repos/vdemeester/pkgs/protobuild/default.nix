{ stdenv, lib, buildGoPackage, fetchgit }:

buildGoPackage rec {
  name = "protobuild-unstable-${version}";
  version = "2018-03-27";
  rev = "e76179fda745e7e601c8c78943191913e3e8a009";

  goPackagePath = "github.com/stevvooe/protobuild";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/stevvooe/protobuild";
    sha256 = "0p8smvf2984kjx3m4qx5ap3005m1df40ynww8rjcrq7gzc3vn61n";
  };

  goDeps = ./deps.nix;

  meta = {
    description = "Build protobufs in Go, easily";
    homepage = https://github.com/stevvooe/protobuild;
    license = lib.licenses.asl20;
  };
}
