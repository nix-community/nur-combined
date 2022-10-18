{ config, pkgs, ... }:

{

  nixpkgs.config.packageOverrides = pkgs: {

    unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
    nixos05 = import <nixos05> { config = { allowUnfree = true; }; };

    nix-software-center = (import (pkgs.fetchFromGitHub {
      owner = "vlinkz";
      repo = "nix-software-center";
      rev = "0.0.3";
      sha256 = "sha256-r5xOi/dd/hW/gdi0X0tHFFt2w82S9PFhZSXPeCA69ig=";
    })) {};


    mipmip_pkg = import (./pkgs) {
      inherit pkgs;
    };
  };

}

