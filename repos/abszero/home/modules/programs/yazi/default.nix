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

  config.programs.yazi = mkIf cfg.enable {
    enable = true;
    shellWrapperName = "y";

    plugins = with pkgs.yaziPlugins; {
      inherit git sudo;
    };

    settings = importTOML ./yazi.toml;
    keymap = importTOML ./keymap.toml;

    initLua = ''
      require("git"):setup()
    '';
  };
}
