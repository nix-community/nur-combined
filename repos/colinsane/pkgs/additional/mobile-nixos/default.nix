{ pkgs
, fetchFromGitHub
}:
let
  src = fetchFromGitHub {
    owner = "nixos";
    repo = "mobile-nixos";
    # XXX: commit `0f3ac0bef1aea70254a3bae35e3cc2561623f4c1`
    # replaces the imageBuilder with a "new implementation from celun" and wildly breaks my use.
    # pinning to d25d3b... is equivalent to holding at 2023-09-15
    rev = "d25d3b87e7f300d8066e31d792337d9cd7ecd23b";
    hash = "sha256-MiVokKlpcJmfoGuWAMeW1En7gZ5hk0rCQArYm6P9XCc=";
  };
  overlay = import "${src}/overlay/overlay.nix";
  final = pkgs.extend overlay;
in src.overrideAttrs (base: {
  # passthru only mobile-nixos' own packages -- not the whole nixpkgs-with-mobile-nixos-as-overlay:
  passthru = base.passthru // (overlay final pkgs);
})
