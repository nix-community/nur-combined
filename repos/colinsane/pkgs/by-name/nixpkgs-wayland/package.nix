{
  fetchFromGitHub,
  lib,
  nix-update-script,
  pkgs,
}:
let
  version = "0-unstable-2025-12-08";
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nixpkgs-wayland";
    rev = "b8d42960897d2141ae5ac69a0d32f918c4be2f37";
    hash = "sha256-94rNAuSPp3IESrzVtH1saE7/U8XGjX0CEdfJG2WFixY=";
  };
  flake = import "${src}/flake.nix";
  evaluated = flake.outputs {
    self = evaluated;
    lib-aggregate.lib = lib // {
      # mock out flake-utils, which it uses to construct flavored package sets.
      # we only need the overlay (unflavored)
      flake-utils.eachSystem = sys: fn: {};
    };
  };
  overlay = evaluated.overlay;

  final = pkgs.extend overlay;
in src.overrideAttrs (base: {
  # attributes required by update scripts
  pname = "nixpkgs-wayland";
  src = src;
  version = version;

  # passthru only nixpkgs-wayland's own packages -- not the whole nixpkgs-with-nixpkgs-wayland-as-overlay:
  passthru = base.passthru // (overlay final pkgs) // {
    updateScript = nix-update-script {
      extraArgs = [ "--version" "branch" ];
    };
  };
})
