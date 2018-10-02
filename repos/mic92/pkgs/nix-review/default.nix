{ nix-review, lib, fetchFromGitHub }:

let 
  version  = "0.5.0-beta2";
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
      sha256 = "0qg5yc180fmf3prwhw137s8a1018l7i0jf6vg0i12lifbjalv9k0";
    };
  })
