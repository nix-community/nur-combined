{ stdenv, lib, buildGoPackage, fetchgit }:

buildGoPackage rec {
  name = "dep-collector-unstable-${version}";
  version = "2018-07-20";
  rev = "ea0470924d0dd9363ffae8936f88a22d28551685";

  goPackagePath = "github.com/mattmoor/dep-collector";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/mattmoor/dep-collector";
    sha256 = "08q6rpvrwlyfci41hvasq24r2cwbp4cyd3885va3irjcb1xlaz93";
  };

  goDeps = ./deps.nix;

  meta = {
    description = "Gathers the set of licenses for Go imports pulled in via dep.";
    homepage = https://github.com/mattmoor/dep-collector;
    license = lib.licenses.asl20;
  };
}
