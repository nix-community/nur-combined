{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption importTOML;
  cfg = config.abszero.programs.yazi;
in

{
  options.abszero.programs.yazi.enable = mkEnableOption "blazing fast terminal file manager";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ripgrep
      trash-cli
    ];
    programs.yazi = {
      enable = true;

      plugins = with pkgs.yaziPlugins; {
        inherit jjui kdeconnect-send sudo;
        git = {
          package = git;
          setup = true;
        };
        recycle-bin = {
          package = recycle-bin;
          setup = true;
        };
      };

      settings = importTOML ./yazi.toml;
      keymap = importTOML ./keymap.toml;
    };
  };
}
