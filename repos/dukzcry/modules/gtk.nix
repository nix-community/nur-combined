{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.gtk;
  gtk2 = cfg.enable && cfg.gtk2;
  disableCsd = cfg.enable && cfg.disableCsd;

  toGtk2File = key: value:
    let
      value' =
        if isBool value then (if value then "true" else "false")
        else if isString value then "\"${value}\""
        else toString value;
    in
      "${key} = ${value'}";
  toGtk3File = generators.toINI {
    mkKeyValue = key: value:
      let
        value' =
          if isBool value then (if value then "true" else "false")
          else toString value;
      in
        "${key}=${value'}";
  };

  settings = theme:
    optionalAttrs (cfg.font != null)
      { gtk-font-name = cfg.font.name; }
    //
    optionalAttrs (theme != null)
      { gtk-theme-name = theme.name; }
    //
    optionalAttrs (cfg.iconTheme != null)
      { gtk-icon-theme-name = cfg.iconTheme.name; }
    //
    optionalAttrs (cfg.cursorTheme != null)
      { gtk-cursor-theme-name = cfg.cursorTheme.name; };

  themeType = types.submodule {
    options = {
      package = mkOption {
        internal = true;
        type = types.nullOr types.package;
        default = null;
      };
      name = mkOption {
        internal = true;
        type = types.str;
      };
    };
  };

  optionalPackage = opt:
    optional (opt != null && opt.package != null) opt.package;
in
{
  options = {
    gtk = {
      enable = mkEnableOption "Gtk theming configuration";

      gtk2 = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable theming for obsolete GTK2 engine.
        '';
      };

      gtk2Theme = mkOption {
        type = types.nullOr themeType;
        default = cfg.theme;
        example = literalExample ''
          {
            name = "Adwaita";
            package = pkgs.gnome-themes-extra;
          };
        '';
        description = "The GTK+ theme to use.";
      };

      disableCsd = mkOption {
        type = types.bool;
        default = true;
      };

      font = mkOption {
        type = types.nullOr themeType;
        default = null;
        example = literalExample ''
          {
            name = "Cantarell 11";
            package = pkgs.cantarell-fonts;
          };
        '';
        description = ''
          The font to use in GTK+ applications.
        '';
      };

      iconTheme = mkOption {
        type = types.nullOr themeType;
        default = null;
        example = literalExample ''
          {
            name = "Adwaita";
            package = pkgs.gnome.adwaita-icon-theme;
          };
        '';
        description = "The icon theme to use.";
      };

      cursorTheme = mkOption {
        type = types.nullOr themeType;
        default = null;
        example = literalExample ''
          {
            name = "Adwaita";
            package = pkgs.gnome.adwaita-icon-theme;
          };
        '';
        description = "The cursor theme to use.";
      };

      theme = mkOption {
        type = types.nullOr themeType;
        default = null;
        example = literalExample ''
          {
            name = "Adwaita";
            package = pkgs.gnome-themes-extra;
          };
        '';
        description = "The GTK+ theme to use.";
      };
    };
  };

  config = mkMerge [

    (mkIf gtk2 {
      environment.etc."xdg/gtk-2.0/gtkrc".text =
        concatStringsSep "\n" (
          mapAttrsToList toGtk2File (settings cfg.gtk2Theme)
        );
    })

    (mkIf disableCsd {
      environment.variables.GTK_CSD = "0";
      environment.variables.LD_PRELOAD = "${pkgs.nur.repos.dukzcry.gtk3-nocsd}/lib/libgtk3-nocsd.so.0";
    })

    (mkIf cfg.enable {
      environment.systemPackages =
        optionalPackage cfg.font
        ++ optionalPackage cfg.theme
        ++ optionalPackage cfg.iconTheme
        ++ optionalPackage cfg.cursorTheme;

      environment.etc."xdg/gtk-3.0/settings.ini".text =
        toGtk3File { Settings = (settings cfg.theme); };

      programs.dconf.enable = lib.mkDefault true;
      programs.dconf.profiles = {
        user.databases = [
          {
            settings = {
              "org/gnome/desktop/interface" =
                optionalAttrs (cfg.font != null)
                  { font-name = cfg.font.name; }
                //
                optionalAttrs (cfg.theme != null)
                  { gtk-theme = cfg.theme.name; }
                //
                optionalAttrs (cfg.iconTheme != null)
                  { icon-theme = cfg.iconTheme.name; }
                //
                optionalAttrs (cfg.cursorTheme != null)
                  { cursor-theme = cfg.cursorTheme.name; };
            };
          }
        ];
      };
    })
  ];
}
