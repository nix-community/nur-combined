{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.steam;
in

{
  options.abszero.programs.steam.enable = mkEnableOption "Steam client";

  config = mkIf cfg.enable {
    # Fix display of CJK characters
    # https://github.com/NixOS/nixpkgs/issues/178121#issuecomment-1173105212
    fonts.packages = with pkgs; [ wqy_zenhei ];
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      gamescopeSession.enable = true;
    };
  };
}
