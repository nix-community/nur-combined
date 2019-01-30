{ stdenv, go, git, fetchgit, buildGoPackage }:

buildGoPackage rec {
  name = "keto-unstable-${version}";
  version = "2019-01-03";
  rev = "7798442553cfe7989a23d2c389c8c63a24013543";

  CGO_ENABLED = 0; 
  buildFlags = "-a -installsuffix cgo ";
   
  goPackagePath = "github.com/ory/keto";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/ory/keto";
    sha256 = "0ybdm0fp63ygvs7cnky4dqgs5rmw7bd1pqkljwb8c2k14ps8xxyf";
  };

  goDeps = ./deps.nix;

  # TODO: add metadata https://nixos.org/nixpkgs/manual/#sec-standard-meta-attributes
  meta = {
  };
}
