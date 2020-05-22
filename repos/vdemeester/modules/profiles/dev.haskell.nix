{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.dev.haskell;
in
{
  options = {
    profiles.dev.haskell = {
      enable = mkEnableOption "Enable haskell development profile";
    };
  };
  config = mkIf cfg.enable {
    profiles.dev.enable = true;
    home.packages = with pkgs; [
      ghc
      stack
      hlint
    ];
  };
}
