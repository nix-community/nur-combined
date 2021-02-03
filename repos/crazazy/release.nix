{ src ? import ./. }:
{
  nurpkgs = src {
    overlays = [
      (self: super: {
        callPackage = super.callNixPackage;
        pkgs = super.callNixPackage ({ pkgs }: pkgs) { };
      })
      (self: super: {
        nur = import (super.lib.ensureModules ./dep/user-pkgs/default.nix) { inherit (super) pkgs; };
      })
    ];
  };
  pkgs = src { };
}
