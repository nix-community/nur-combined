{ go, stdenv, fetchgit, buildGoPackage }:

buildGoPackage rec {
  name = "keto-unstable-${version}";
  version = "7798442553cfe7989a23d2c389c8c63a24013543";


  goDeps=./deps.nix;
  buildFlags = "-v -a -installsuffix cgo ";

  goPackagePath = "github.com/ory/keto";

  patches = [ ./0001-keto-changes.patch ];

  src = fetchgit {
    rev = version;
    url = "https://github.com/ory/keto";
    sha256 = "0ybdm0fp63ygvs7cnky4dqgs5rmw7bd1pqkljwb8c2k14ps8xxyf";
  };

  dontInstallSrc = true;
  # TODO: add metadata https://nixos.org/nixpkgs/manual/#sec-standard-meta-attributes
  meta = {
  };

}
