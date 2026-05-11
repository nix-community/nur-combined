{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.zed-editor;
in
{
  options.programs.zed-editor = {
    githubPatSecret = lib.mkOption {
      type = lib.types.str;
      default = "github_toyvo_pat";
      description = "Name of the sops secret containing the GitHub PAT for Zed.";
    };
  };

  #

  config = lib.mkIf cfg.enable {
    xdg.configFile."zed/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixcfg/modules/home/programs/editors/zed-settings.json";
    home.packages = [ cfg.package ];
  };
}
