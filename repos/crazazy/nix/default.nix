let
  sources = import ./sources.nix;
  hmNixos = import sources.home-manager { inherit pkgs; };
  NUR = import sources.NUR { inherit pkgs; };
  pkgs = import sources.nixpkgs {
    overlays = [
      overlay
    ];
  };
  overlay = self: super: {
    inherit sources hmNixos;
  } // NUR;
in
{
  inherit sources pkgs overlay;
  nixos = (import "${sources.nixpkgs-channels}/nixos" { configuration = ../configuration.nix; }).system;
}
