{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.dev.rust;
in
{
  options = {
    profiles.dev.rust = {
      enable = mkEnableOption "Enable rust development profile";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      profiles.dev.enable = true;
      home.packages = with pkgs; [
        gcc
        rustup
      ];
    }
    (
      mkIf config.profiles.emacs.enable {
        home.packages = with pkgs; [
          rustracer
        ];
      }
    )
  ]);
}
