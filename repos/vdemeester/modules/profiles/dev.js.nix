{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.dev.js;
in
{
  options = {
    profiles.dev.js = {
      enable = mkEnableOption "Enable js development profile";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.file.".npmrc".text = ''
        prefix = ${config.home.homeDirectory}/.local/npm
      '';
      home.packages = with pkgs; [
        nodejs-10_x
        yarn
      ];
    }
    (
      mkIf config.profiles.fish.enable {
        xdg.configFile."fish/conf.d/js.fish".text = ''
          set -gx PATH ${config.home.homeDirectory}/.local/npm/bin $PATH
        '';
      }
    )
  ]);
}
