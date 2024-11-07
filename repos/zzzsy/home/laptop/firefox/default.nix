{ pkgs, lib, ... }:

let
  userJs = "${pkgs.my.firefox-gnome-theme}/share/firefox-theme/configuration/user.js";
  userChrome = "${pkgs.my.firefox-gnome-theme}/share/firefox-theme/userChrome.css";
  userContent = "${pkgs.my.firefox-gnome-theme}/share/firefox-theme/userContent.css";
in

{
  programs.librewolf = {
    enable = true;
    package = pkgs.wrapFirefox pkgs.librewolf-unwrapped {
      wmClass = "LibreWolf";
      libName = "librewolf";
      extraPolicies = {
        ExtensionSettings = import ./config/extensions.nix;
        DisablePocket = true;
        DisableTelemetry = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
      };
    };
    #@TODO muilti profile
    profiles.default = {
      isDefault = true;
      settings = import ./config/settings.nix;
      search = import ./config/search.nix;
      userChrome = lib.strings.concatStrings [
        ''
          @import "${userChrome}";
        ''
        (builtins.readFile ./config/custom/sidebery_dyn.css)
        (builtins.readFile ./config/custom/userChrome.css)
      ];
      userContent = lib.strings.concatStrings [
        ''
          @import "${userContent}";
        ''
        (builtins.readFile ./config/custom/userContent.css)
      ];
      extraConfig = lib.strings.concatStrings [
        (builtins.readFile "${userJs}")
        ''''
      ];
    };
  };
}
