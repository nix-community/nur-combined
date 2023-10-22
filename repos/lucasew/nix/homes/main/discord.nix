{ pkgs, lib, config, ... }:

{
  options.programs.discord.enable = lib.mkEnableOption "discord-desktop";

  config = lib.mkIf config.programs.discord.enable {
    home.packages = [ pkgs.discord ];
  };
}
