{ pkgs
, fetchFromGitHub
, lib
, nix-update-script
}:
let
  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nixpkgs-wayland";
    rev = "a9dc00e807fc891d096ca8cbb3c129a13c90f717";
    hash = "sha256-nyR6Gt8AsM4cbM1701TAX5Q9Xk2cYKmP4JCn8ejS+9g=";
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
  version = "0-unstable-2025-01-21";
  src = src;

  # passthru only nixpkgs-wayland's own packages -- not the whole nixpkgs-with-nixpkgs-wayland-as-overlay:
  passthru = base.passthru // (overlay final pkgs) // {
    updateScript = nix-update-script {
      extraArgs = [ "--version" "branch" ];
    };
  };
})
