{ nixpkgs-review, lib, fetchFromGitHub }:
let
  version = "2.3.0-rc1";
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
        sha256 = "026lmwbvqdp7a3nkd08rd0nfyb9yiic36w6s7mh2rpp0ihp7qsd6";
      };
    }
  )
