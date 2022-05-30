{ config, pkgs, ... }:

{

  nixpkgs.config.packageOverrides = pkgs: {

    unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
    nixos05 = import <nixos05> { config = { allowUnfree = true; }; };

    mipmip_pkg = import (./pkgs) {
      inherit pkgs;
    };
  };

}

