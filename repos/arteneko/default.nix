{
  pkgs ? import <nixpkgs> {}
}:
{
  # my packages
  cap = pkgs.callPackage ./pkgs/cap.nix {};
  gls-vim = pkgs.callPackage ./pkgs/gls-vim.nix {};
  svg = pkgs.callPackage ./pkgs/svg.nix {};

  # my nixos and home-manager options (TBD, e.g. for services)
}
