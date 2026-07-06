{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.zed-editor;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."zed/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcfg/modules/home/programs/editors/zed-settings.json";
    home.packages = [ cfg.package ];
  };
}
