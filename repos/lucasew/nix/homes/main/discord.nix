{ pkgs, lib, config, ... }:

{
  options.programs.discord.enable = lib.mkIf "discord-desktop";

  config = lib.mkIf config.programs.discord.enable {
    home.packages = [ pkgs.discord ];
  };
}
