{ config, lib, pkgs, wrapFirefox, ... }:

with lib;

let

  cfg = config.kampka.programs.firefox;

  userSettings = {"foo" = "bar";};
  fox = pkgs.callPackage ./firefox.nix { userSettings = cfg.userSettings; userPolicies = cfg.userPolicies; };

in {
  options.kampka.programs.firefox = {
    enable = mkEnableOption "Firefox with strict settings";

    userSettings = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        Setting to be applied to firefox as hard defaults.
        These settings cannot be changed via UI, about:config or remote sync/API.
        The set defined here must serialize to a key/value pair where keys are always strings and values are the Nix representations of the JSON value valid for the given key.
        All valid key/value pairs are listed in about:config.
        See also https://developer.mozilla.org/en-US/docs/Mozilla/Preferences/A_brief_guide_to_Mozilla_preferences
        '';
      example = {
        "browser.search.region" = "US";
        "geo.enabled" = true;
        "browser.startup.page" = 1;
      };
    };

    userPolicies = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        Policies allow additional control over Firefox settings in addition or sometimes beyond the scope of userSettings.
        The set defined here must serialize to a key/value pair where keys are always strings and values are the Nix representations of the JSON value valid for the given key.
        See https://github.com/mozilla/policy-templates/blob/master/README.md for details.
        '';
      example = {
        "DisableFirefoxScreenshots" = true;
        "Extensions" = {
          "Install" = ["//path/to/xpi"];
        };
      };
    };
  };

  config = mkIf cfg.enable {
      environment.systemPackages = [ fox ];
  };
}
