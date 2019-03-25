{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.lsd;
in

{
  ###### interface

  options = {
    programs.lsd = {
      enable = mkEnableOption "<command>lsd</command> command + font";
    };
  };

  config = lib.mkIf cfg.enable ({
    environment.systemPackages = [ pkgs.lsd ];
    fonts.fonts = [ pkgs.nerdfonts ];
  });
}
