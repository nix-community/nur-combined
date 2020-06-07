{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.firefox;
in
{
  options = {
    programs.firefox = {
      privacy = mkOption {
        type = types.submodule {
          options = {
            extensions = mkOption {
              type = types.submodule {
                options = {
                  enable = mkOption {
                    type = types.bool;
                    default = false;
                    description = ''
                      Enables various privacy addons for Firefox,
                      as recommended by
                      https://www.privacytools.io/browsers/#addons
                    '';
                  };
                  repository = mkOption {
                    type = types.nullOr types.attrs;
                    default = null;
                    defaultText = literalExample "pkgs.nur.repos.rycee.firefox-addons";
                    description = ''
                      Where to fetch the extensions from. Note that there's no
                      firefox extensions library bundled with home-manager;
                      the default is coming from rycee's NUR repository, which
                      requires you to add Nix User Repositories as an
                      overlay. You're also required to enable the specified
                      extensions, as described by
                      <option>programs.firefox.extensions</option>.
                    '';
                  };
                };
              };
              default = {};
              description = ''
                Whether or not to install privacy-related extensions.
              '';
            };
            default = {};
          };
        };
        default = {};
        description = ''
          Global privacy-related options
        '';
      };
      profiles = mkOption {
        type = types.attrsOf (types.submodule ({ config, ... }: {
          options = {
            privacy = mkOption {
              type = types.submodule {
                options = {
                  enableSettings = mkOption {
                    type = types.bool;
                    default = false;
                    description = ''
                      Enables various privacy settings for Firefox, as
                      recommended by
                      https://www.privacytools.io/browsers/#about_config
                    '';
                  };
                };
              };
              default = {};
              description = ''
                Privacy-related profile options
              '';
            };
          };
          config = {
            settings = mkIf config.privacy.enableSettings {
              # Privacy recommendations from https://www.privacytools.io/browsers/#about_config
              "privacy.firstparty.isolate"                        = true;
              "privacy.resistFingerprinting"                      = true;
              "privacy.trackingprotection.fingerprinting.enabled" = true;
              "privacy.trackingprotection.cryptomining.enabled"   = true;
              "privacy.trackingprotection.enabled"                = true;
              "browser.send_pings"                                = false;
              "browser.urlbar.speculativeConnect.enabled"         = false;
              "dom.event.clipboardevents.enabled"                 = false;
              "media.eme.enabled"                                 = false;
              "media.gmp-widevinecdm.enabled"                     = false;
              "media.navigator.enabled"                           = false;
              "network.cookie.cookieBehavior"                     = 1;
              "network.http.referer.XOriginPolicy"                = 2;
              "network.http.referer.XOriginTrimmingPolicy"        = 2;
              "webgl.disabled"                                    = true;
              "browser.sessionstore.privacy_level"                = 2;
              "network.IDN_show_punycode"                         = true;
            };
          };
        }));
      };
    };
  };
  config = {
    programs.firefox = {
      extensions = let
        repo = cfg.privacy.extensions.repository;
        repoOrDefault = if repo != null then repo else pkgs.nur.repos.rycee.firefox-addons;
      in mkIf cfg.privacy.extensions.enable (with repoOrDefault; [
        # Privacy addons: https://www.privacytools.io/browsers/#addons
        ublock-origin
        https-everywhere
        decentraleyes
        cookie-autodelete
        privacy-badger
        # TODO: tosdr
        # Skipping "Snowflake", users should need to opt-in
        # NoScript and uMatrix are too advanced for the average user :)
      ]);
    };
  };
}
