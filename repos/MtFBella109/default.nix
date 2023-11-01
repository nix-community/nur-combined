{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> { inherit system; } }:


rec {
  catppuccin-frappe = pkgs.callPackage ./pkgs/sddm-themes/catppuccin-frappe { };

  catppuccin-latte = pkgs.callPackage ./pkgs/sddm-themes/catppuccin-latte { };

  catppuccin-macchiato = pkgs.callPackage ./pkgs/sddm-themes/catppuccin-macchiato { };

  catppuccin-mocha = pkgs.callPackage ./pkgs/sddm-themes/catppuccin-mocha { };

}
