{ stdenv, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "logico-unstable-${version}";
  version = "2019-02-27";
  rev = "9b369601ebbfc4820fe2ddb4efe6b5d51f9aee10";

  goPackagePath = "github.com/piensa/logico";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/piensa/logico";
    sha256= "1s9wagk9y7cwpnbgynqizy9ldjfvinja5nyprw8pvm9xbcjxc4pa";
  };

  goDeps = ./deps.nix;

  # TODO: add metadata https://nixos.org/nixpkgs/manual/#sec-standard-meta-attributes
  meta = {
  };
}
