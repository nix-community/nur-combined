{ pkgs ? import <nixpkgs> { } }:
let
  version = "1.1.0";

  repo = pkgs.fetchFromGitHub {
    owner = "Xe";
    repo = "johaus";
    rev = "v${version}";
    sha256 = "0nwcfv40mhiyp2zzzsxg0j7717asdmhshg40dbnkwmqwhiqikdnb";
  };

  out = pkgs.buildGoModule {
    pname = "johaus";
    version = version;
    src = repo;
    vendorSha256 = "10l9rlsqkksnwjac7hwgjzrx5n4maad4nbdsa2zrjmnjsh09224j";

    subPackages = [ "." ];
  };

in out
