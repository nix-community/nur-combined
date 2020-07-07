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
    modSha256 = "1s3yj3b5zs9cqss2p2qdsk5yxmwna53nnk62zf78j6whan2kqags";
    vendorSha256 = "1s3yj3b5zs9cqss2p2qdsk5yxmwna53nnk62zf78j6whan2kqag3";

    subPackages = [ "." ];
  };

in out
