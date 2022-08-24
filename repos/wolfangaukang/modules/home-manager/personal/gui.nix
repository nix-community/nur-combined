{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.defaultajAgordoj.gui;
  bcfg = cfg.browsers;
  settings = import ./settings.nix { inherit pkgs; };

in
{
  meta.maintainers = [ wolfangaukang ];

  options.defaultajAgordoj.gui = {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables the GUI tools, plus Feh as image viewer.
      '';
    };
    enableMimeapps = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables mimeapps management.
      '';
    };
    browsers = {
      firefox = {
        enable = mkOption {
          default = true;
          type = types.bool;
          description = ''
            Enables Firefox as a browser with its current settings.
          '';
        };
        package = mkOption {
          default = settings.firefox.package;
          type = types.package;
          description = ''
            Firefox package to use.
          '';
        };
      };
      chromium = {
        enable = mkOption {
          default = false;
          type = types.bool;
          description = ''
            Enables Chromium as a browser with its current settings.
          '';
        };
        package = mkOption {
          default = pkgs.brave;
          type = types.package;
          description = ''
            Chromium browser to use.
          '';
        }; 
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = settings.packages.gui;
      programs.feh.enable = true;
      xdg.mimeApps = {
        enable = cfg.enableMimeapps;
        defaultApplications = settings.mimelist;
      };
    }
    (mkIf bcfg.firefox.enable {
      home.packages = settings.firefox.extraPkgs;
      programs.firefox = {
        enable = true;
        package = bcfg.firefox.package;
        extensions = settings.firefox.extensions;
        profiles = {
          default = {
            name = "Sandbox";
            settings = lib.mkMerge [
              settings.firefox.settings.common
              settings.firefox.settings.sandbox
            ];
          };
          personal = {
            id = 1;
            name = "Personal";
            settings = lib.mkMerge [
              settings.firefox.settings.common
            ];
          };
          gnaujep = {
            id = 2;
            name = "Gnaujep";
            settings = lib.mkMerge [
              settings.firefox.settings.common
            ];
          };
        };
      };
    })
    (mkIf bcfg.chromium.enable {
      home.packages = settings.packages.browser;
      programs.chromium = {
        enable = true;
        package = bcfg.chromium.package;
        extensions = settings.chromium.extensions;
      };
    })
  ]);
}
