{ stdenv, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "dbxcli-unstable-${version}";
  version = "2019-06-10";
  rev = "a871c88";

  goPackagePath = "github.com/dropbox/dbxcli";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/dropbox/dbxcli";
    sha256= "1cdijn04fwgk7qapbv11v690i77s9j5z0cvbd2qjkp1aldw0figi";
  };

  goDeps = ./deps.nix;

  # TODO: add metadata https://nixos.org/nixpkgs/manual/#sec-standard-meta-attributes
  meta = {
  };
}
