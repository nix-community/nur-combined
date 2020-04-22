{ nixpkgs-review, lib, fetchFromGitHub }:
let
  version = "2.3.0-rc2";
in
if lib.versionOlder version nixpkgs-review.version then
  nixpkgs-review
else
  nixpkgs-review.overrideAttrs (
    old: {
      name = "nixpkgs-review-${version}";
      inherit version;

      src = fetchFromGitHub {
        owner = "Mic92";
        repo = "nixpkgs-review";
        rev = version;
        sha256 = "1pr09kyawz9cicc2fg6099wxxyx5ybk32y3cy91jwkw2wc2ycskb";
      };
    }
  )
