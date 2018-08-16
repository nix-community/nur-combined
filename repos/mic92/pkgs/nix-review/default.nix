{ nix-review, fetchFromGitHub }:

nix-review.overrideAttrs (old: rec {
  name = "nix-review-${version}";
  version = "0.5.0-beta";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nix-review";
    rev = version;
    sha256 = "153kyhwn228lflsszaj97kc2dipmwxz712iw1gi12f8dv305gmik";
  };
})
