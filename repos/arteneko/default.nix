{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; }
}:
rec {
  # my packages
  cap = pkgs.callPackage ./pkgs/cap.nix {};

  vimPlugins = {
    gls-vim = pkgs.callPackage ./pkgs/gls-vim.nix {};
  };

  # my nixos and home-manager options (TBD, e.g. for services)
}
