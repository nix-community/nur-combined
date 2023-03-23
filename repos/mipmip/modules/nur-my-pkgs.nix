{ config, pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: {

    mipmip_pkg = import (../pkgs) {
      inherit pkgs;
    };

  };

}
