{ inputs
, config
, lib
, pkgs
, ... }:

let
  inherit (lib) maintainers types mkIf mkMerge mkOption;
  inherit (inputs) self;
  cfg = config.defaultajAgordoj.gui;
  bcfg = cfg.browsers;

  mimelist = {
    "application/xml" = "neovim.desktop";
    "application/x-perl" = "neovim.desktop";
    "image/jpeg" = "feh.desktop";
    "image/png" = "feh.desktop";
    "text/mathml" = "neovim.desktop";
    "text/plain" = "neovim.desktop";
    "text/xml" = "neovim.desktop";
    "text/x-c++hdr" = "neovim.desktop";
    "text/x-c++src" = "neovim.desktop";
    "text/x-xsrc" = "neovim.desktop";
    "text/x-chdr" = "neovim.desktop";
    "text/x-csrc" = "neovim.desktop";
    "text/x-dtd" = "neovim.desktop";
    "text/x-java" = "neovim.desktop";
    "text/x-python" = "neovim.desktop";
    "text/x-sql" = "neovim.desktop";
    "text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;" = "neovim.desktop";
     "x-scheme-handler/http" = "firefox.desktop";
     "x-scheme-handler/https" = "firefox.desktop";
     "x-scheme-handler/about" = "firefox.desktop";
     "x-scheme-handler/unknown" = "firefox.desktop";
  };

in {
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
    extraPkgs = mkOption {
      default = [ ];
      type = types.listOf types.package;
      description = ''
        List of extra packages to install
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = cfg.extraPkgs;
      programs.feh.enable = true;
      xdg.mimeApps = {
        enable = cfg.enableMimeapps;
        defaultApplications = mimelist;
      };
    }
    (mkIf bcfg.firefox.enable (import "${self}/home/profiles/programs/firefox.nix" {
       inherit pkgs lib self;
       firefox-pkg = bcfg.firefox.package;
     }))
    (mkIf bcfg.chromium.enable (import "${self}/home/profiles/programs/chromium.nix" {
       inherit pkgs;
       chromium-pkg = bcfg.chromium.package;
     }))
  ]);

  meta.maintainers = with maintainers; [ wolfangaukang ];
}
