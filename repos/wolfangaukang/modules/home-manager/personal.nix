{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.defaultajAgordoj;
  bcfg = cfg.gui.browsers;
  settings = import ./settings { inherit pkgs; };

in
{
  meta.maintainers = [ wolfangaukang ];

  options.defaultajAgordoj = {
    cli.enable = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Enables the CLI tools, plus the common Git, GPG, Neovim, Pass and SSH settings.
      '';
    };
    gui = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enables the GUI tools, plus Feh as image viewer.
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
  };

  config = (mkMerge [
    (mkIf cfg.cli.enable {
      home.packages = settings.cli-tools;
      programs = {
        git = {
          enable = true;
          extraConfig.init.defaultBranch = "main";
          signing = {
            key = "F90110C7";
            signByDefault = true;
          };
          userName = "P. R. d. O.";
          userEmail = "d.ol.rod@tutanota.com";
        };
        gpg.enable = true;
        neovim = {
          enable = true;
          package = pkgs.neovim-unwrapped;
          plugins = with pkgs.vimPlugins; [
            vim-nix
          ];
          viAlias = true;
        };
        ssh = {
          enable = true;
          matchBlocks = {
            surtsey = {
              hostname = "192.168.8.203";
              user = "marx";
              identityFile = ["~/.ssh/surtsey"];
            };
          };
        };
      };
      services = {
        gpg-agent = {
          enable = true;
          enableScDaemon = false;
          pinentryFlavor = "curses";
        };
      };
    })
    (mkIf cfg.gui.enable (mkMerge [
      {
        home.packages = settings.gui-tools ++ [ pkgs.nur.repos.wolfangaukang.vdhcoapp ];
        programs.feh.enable = true;
        xdg.mimeApps = {
          enable = true;
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
          };
        };
      })
      (mkIf bcfg.chromium.enable {
        home.packages = settings.browser-common;
        programs.chromium = {
          enable = true;
          package = bcfg.chromium.package;
          extensions = settings.chromium-extensions;
        };
      })
    ]))
  ]);
}