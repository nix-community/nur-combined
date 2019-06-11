{ stdenv, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "reva-unstable-${version}";
  version = "2019-06-10";
  rev = "f648cd9";

  goPackagePath = "github.com/cs3org/reva";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/cs3org/reva";
    sha256= "07vjgzga77gn3n2razb9sjqga5yw8aa2mbydg48g641xadl35f57";
  };

  goDeps = ./deps.nix;

  # TODO: add metadata https://nixos.org/nixpkgs/manual/#sec-standard-meta-attributes
  meta = {
  };
}
