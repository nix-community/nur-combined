{ nix-review, lib, fetchFromGitHub }:

let 
  version  = "1.0.0-rc1";
in if lib.versionOlder version nix-review.version then
  nix-review
else
  nix-review.overrideAttrs (old: {
    name = "nix-review-${version}";
    inherit version;

    src = fetchFromGitHub {
      owner = "Mic92";
      repo = "nix-review";
      rev = version;
      sha256 = "1f9bdqzwxb6ii674fiajvz2qgcjklfsxzrq06hlm0fc1damg4xbv";
    };
  })
