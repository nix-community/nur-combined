{ config ? {}, lib, pkgs, ... }:
let
  # upstream = (import ~/src/nixos/nixpkgs {});
  self = (import ../../.. {});
  hm = self.hm;
in
{
  # -- Actual Config ---
  imports = lib.attrValues hm.rawModules;

  home.packages = hm.base ++ [
    pkgs.tilix
  ];

  programs.crostini.enable = true;
  programs.crostini.docker.enable = true;

  programs.dev.enable = true;
  programs.base.enable = true;

  services.keybase.enable = true;
  services.kbfs.enable = true;
}
