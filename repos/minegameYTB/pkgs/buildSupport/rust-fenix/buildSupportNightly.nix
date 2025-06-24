{ pkgs }:
let
  fenix = pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "fenix";
    rev = "9be40ad995bac282160ff374a47eed67c74f9c2a"; # June 2025
    hash = "sha256-MJNhEBsAbxRp/53qsXv6/eaWkGS8zMGX9LuCz1BLeck=";
  };
  toolchain = (import fenix { inherit pkgs; }).minimal;
in
  toolchain

