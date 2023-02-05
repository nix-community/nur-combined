{
  pkgs ? import <nixpkgs> {}
}:
{
  # my packages
  cap = pkgs.callPackage ./pkgs/cap.nix {};
  svg = pkgs.callPackage ./pkgs/svg.nix {};

  gls-vim = pkgs.callPackage ./pkgs/gls-vim.nix {};
  janet-vim = pkgs.callPackage ./pkgs/janet-vim.nix {};

  # my nixos and home-manager options (TBD, e.g. for services)
}
