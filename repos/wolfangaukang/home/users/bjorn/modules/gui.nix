{ inputs
, config
, lib
, pkgs
, ... }:

let
  inherit (lib) maintainers types mkIf mkMerge mkOption;
  inherit (inputs) self dotfiles;
  cfg = config.defaultajAgordoj.gui;
  jsonFormat = pkgs.formats.json { };
  bcfg = cfg.browsers;
  settings = {
    vscode = import ../settings/vscode.nix { inherit pkgs; };
    chromium = import ../settings/chromium.nix;
    firefox = import ../settings/firefox { inherit config lib pkgs; };
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
    # The reason for this is to not install gui components on cli-only setups
    extraPkgs = mkOption {
      default = [];
      type = types.listOf types.package;
      description = ''
        List of packages to install when this module is enabled
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
    terminal = {
      enableAlacritty = mkOption {
        default = true;
        type = types.bool;
        description = ''
          Enables Alacritty terminal
        '';
      };
      enableKitty = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enables Kiity terminal
        '';
      };
    };
    vscode = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enables VSCode
        '';
      };
      package = mkOption {
        default = pkgs.vscodium;
        type = types.package;
        description = ''
          VSCode variant to use
        '';
      };
      extraExtensions = mkOption {
        default = [];
        type = types.listOf types.package;
        description = ''
          VSCode extensions to install
        '';
      };
      extraSettings = mkOption {
        default = {};
        type = jsonFormat.type;
        description = ''
          Settings to add to the extra settings
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.feh.enable = true;
      xdg.mimeApps = {
        enable = cfg.enableMimeapps;
        #defaultApplications = mimelist;
      };
      home.packages = cfg.extraPkgs;
    }
    (mkIf cfg.vscode.enable {
      programs.vscode = {
        enable = true;
        package = cfg.vscode.package;
        extensions = settings.vscode.extensions;
        userSettings = settings.vscode.settings;
      };
    })
    (mkIf bcfg.firefox.enable {
       programs.firefox =
         {
           enable = true;
           package = settings.firefox.package;
           profiles = settings.firefox.profiles;
         };
       home.packages = with pkgs; [ vdhcoapp ];
     })
    (mkIf bcfg.chromium.enable {
       programs.chromium = {
         enable = true;
         package = bcfg.chromium.package;
         extensions = settings.chromium.extensionCodes;
       };
     })
    (mkIf cfg.terminal.enableAlacritty {
       programs.alacritty.enable = true;
       home.file.".config/alacritty/alacritty.yml".source = "${dotfiles}/config/alacritty/config.yml";
     })
    (mkIf cfg.terminal.enableKitty {
       programs.kitty = {
         enable = true;
         # Need to solve this
         #package = iosevka-nerdfonts;
         #name = "Iosevka Term";
       };
     })
  ]);

  meta.maintainers = with maintainers; [ wolfangaukang ];
}
