{ stdenv, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "jivan-unstable-${version}";
  version = "2018-03-28";
  rev = "5bf0b77";

  goPackagePath = "github.com/go-spatial/jivan";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/go-spatial/jivan";
    sha256 = "10gkqqf62h95p1x05v9j7a8kinc0myyqrccmh9qwzvcxpx9gm9lm";
  };

  goDeps = ./deps.nix;

  # TODO: add metadata https://nixos.org/nixpkgs/manual/#sec-standard-meta-attributes
  meta = {
  };
}
