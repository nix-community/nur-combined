{ config, lib, pkgs, ... }:

let
  inherit (lib) maintainers types mkIf mkMerge mkOption;
  cfg = config.defaultajAgordoj.gui;
  bcfg = cfg.browsers;
  settings = import ./settings.nix { inherit pkgs; };

in
{
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
          default = null;
          type = types.nullOr types.package;
          description = ''
            Firefox package to use. Currently using null as the module
            has a customized package
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
    (mkIf bcfg.firefox.enable (import ../../profiles/common/firefox.nix {
       inherit pkgs lib;
       firefox-pkg = bcfg.firefox.package;
     }))
    (mkIf bcfg.chromium.enable (import ../../profiles/common/chromium.nix {
       inherit pkgs;
       chromium-pkg = bcfg.chromium.package;
     }))
  ]);

  meta.maintainers = with maintainers; [ wolfangaukang ];
}
