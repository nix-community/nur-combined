{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    types
    mkEnableOption
    mkOption
    mkIf
    ;
  cfg = config.abszero.programs.firefox;
in

{
  options.abszero.programs.firefox = {
    enable = mkEnableOption "managing Firefox";
    profile = mkOption {
      type = types.nonEmptyStr;
      default = config.home.username;
    };
  };

  config = mkIf cfg.enable {
    # Make dev edition use the same profile as the normal Firefox.
    home.file.".mozilla/firefox/ignore-dev-edition-profile".text = "";

    programs.firefox = {
      enable = true;
      package = pkgs.firefox-devedition-bin;
      profiles.${cfg.profile}.settings = {
        "browser.aboutConfig.showWarning" = false;
      };
    };
  };
}
