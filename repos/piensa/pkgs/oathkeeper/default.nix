{ stdenv, go, git, fetchgit, buildGoPackage }:

buildGoPackage rec {
  name = "oathkeeper-unstable-${version}";
  version = "2019-01-03";
  rev = "2d9899a38b927ff367931c024a10bfdc3230e9a3";

  goPackagePath = "github.com/ory/oathkeeper";
  
  CGO_ENABLED = 0; 
  buildFlags = "-a -installsuffix cgo ";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/ory/oathkeeper";
    sha256 = "03ss3i3fz4skppfin36bzikjgsrys46api68qpj4rw3w7m4af0jk";
  };

  goDeps = ./deps.nix;

  # TODO: add metadata https://nixos.org/nixpkgs/manual/#sec-standard-meta-attributes
  meta = {
  };
}
