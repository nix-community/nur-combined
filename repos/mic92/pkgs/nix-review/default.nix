{ nix-review, fetchFromGitHub }:

nix-review.overrideAttrs (old: rec {
  name = "nix-review-${version}";
  version = "0.5.0-beta2";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-review";
    rev = version;
    sha256 = "0qg5yc180fmf3prwhw137s8a1018l7i0jf6vg0i12lifbjalv9k0";
  };
})
