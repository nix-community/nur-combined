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
      profiles.${cfg.profile}.settings = {
        "services.sync.username" = findName
          (_: v: v.primary)
          config.accounts.email.accounts;
        "browser.aboutConfig.showWarning" = false;
      };
    };
    home.file = {
      # Make dev edition use the same profile as the normal Firefox.
      ".mozilla/firefox/ignore-dev-edition-profile".text = "";
      # Workaround to add plasma-browser-integration to the native messaging hosts.
      # https://github.com/NixOS/nixpkgs/issues/47340#issuecomment-440645870
      ".mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json".source =
        pkgs.libsForQt5.plasma-browser-integration + "/lib/mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json";
    };
  };
}
