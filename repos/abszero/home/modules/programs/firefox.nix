{ config, pkgs, lib, ... }:

let
  inherit (lib) types mkEnableOption mkOption mkIf;
  inherit (lib.abszero.attrsets) findName;
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
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-devedition-bin;
      nativeMessagingHosts =
        with pkgs;
        mkIf config.abszero.services.desktopManager.plasma6.enable
          [ kdePackages.plasma-browser-integration ];
      profiles.${cfg.profile}.settings = {
        "services.sync.username" = findName
          (_: v: v.primary)
          config.accounts.email.accounts;
        "browser.aboutConfig.showWarning" = false;
      };
    };

    # Make dev edition use the same profile as the normal Firefox.
    home.file.".mozilla/firefox/ignore-dev-edition-profile".text = "";
  };
}
