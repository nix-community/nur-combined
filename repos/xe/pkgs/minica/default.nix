{ pkgs ? import <nixpkgs> { } }:
let
  version = "1.0.2";

  repo = pkgs.fetchFromGitHub {
    owner = "jsha";
    repo = "minica";
    rev = "v${version}";
    sha256 = "18518wp3dcjhf3mdkg5iwxqr3326n6jwcnqhyibphnb2a58ap7ny";
  };

  out = pkgs.buildGoModule {
    pname = "minica";
    version = version;
    src = repo;
    modSha256 = "0sjjj9z1dhilhpc8pq4154czrb79z9cm044jvn75kxcjv6v5l2m5";
    vendorSha256 = "1s3yj3b5zs9cqss2p2qdsk5yxmwna53nnk62zf78j6whan2kqag3";

    subPackages = [ "." ];
  };

in out
