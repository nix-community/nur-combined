{ config
, lib
, pkgs
, ...
}:

let
  inherit (lib) maintainers types mkEnableOption mkIf mkMerge mkOption;
  cfg = config.defaultajAgordoj.gui;
  ccfg = config.defaultajAgordoj.cli;
  jsonFormat = pkgs.formats.json { };
  bcfg = cfg.browsers;
  settings = {
    vscode = import ../settings/vscode.nix { inherit pkgs; };
    chromium = import ../settings/chromium.nix;
    firefox = import ../settings/firefox { inherit config lib pkgs; };
    alacritty = import ../settings/alacritty.nix {
      size = cfg.terminal.alacritty.font.size;
      fontFamily = cfg.terminal.alacritty.font.family;
    };
    kitty = import ../settings/kitty.nix {
      font = cfg.terminal.kitty.font;
      theme = cfg.terminal.kitty.theme;
    };
  };

  terminalFontType = types.submodule {
    options = {
      size = mkOption {
        default = 8.0;
        type = types.number;
        description = ''
          Font size to apply to all terminals
        '';
      };
      family = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = ''
          Font family to apply to all terminals
        '';
      };
      package = mkOption {
        default = null;
        type = types.nullOr types.package;
        description = ''
          Package where the fonts are located
        '';
      };
    };
  };

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
    # The reason for this is to not install gui components on cli-only setups
    extraPkgs = mkOption {
      default = [ ];
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
      font = mkOption {
        type = types.nullOr terminalFontType;
        default = null;
        description = "Font setup to use on all terminals";
      };
      kitty = {
        enable = mkEnableOption "Enables Kitty Terminal" // { default = true; };
        font = mkOption {
          type = types.nullOr terminalFontType;
          default = cfg.terminal.font;
          description = "Font setup to use on Kitty";
        };
        theme = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Theme to use on Kitty";
        };
      };
      alacritty = {
        enable = mkEnableOption "Enables Alacritty terminal";
        font = mkOption {
          type = types.nullOr terminalFontType;
          default = cfg.terminal.font;
          description = "Font setup to use on Alacritty";
        };
        theme = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Theme to use on Alacritty";
        };
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
        default = [ ];
        type = types.listOf types.package;
        description = ''
          VSCode extensions to install
        '';
      };
      extraSettings = mkOption {
        default = { };
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
    (mkIf cfg.terminal.alacritty.enable {
      programs.alacritty = {
        enable = true;
        settings = settings.alacritty;
      };
    })
    (mkIf cfg.terminal.kitty.enable {
      programs.kitty = {
        enable = true;
        font = settings.kitty.font;
        theme = settings.kitty.theme;
        shellIntegration = {
          mode = settings.kitty.shellIntegrationMode;
          enableFishIntegration = ccfg.shell.enableFish;
          enableZshIntegration = ccfg.shell.enableZsh;
        };
      };
    })
  ]);

  meta.maintainers = with maintainers; [ wolfangaukang ];
}
