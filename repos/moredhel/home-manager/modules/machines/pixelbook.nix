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
  ];

  programs.crostini.enable = true;
  programs.dev.enable = true;

  services.keybase.enable = true;
  services.kbfs.enable = true;
  programs.bash.enable = true;
}
