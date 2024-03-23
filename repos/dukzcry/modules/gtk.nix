# https://github.com/nix-community/home-manager/blob/master/modules/misc/gtk.nix

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.gtk;
  disableCsd = cfg.enable && cfg.disableCsd;
  fixDialogs = cfg.enable && cfg.fixDialogs && config.qt.platformTheme == "gnome";

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

  gtk4Css = optionalString (notNull cfg.theme "package" && notNull cfg.theme "name") ''
    @import url("file://${cfg.theme.package}/share/themes/${cfg.theme.name}/gtk-4.0/gtk.css");
  '';

  settings =
    optionalAttrs (notNull cfg.font "name")
      { gtk-font-name = cfg.font.name; }
    //
    optionalAttrs (notNull cfg.theme "name")
      { gtk-theme-name = cfg.theme.name; }
    //
    optionalAttrs (notNull cfg.iconTheme "name")
      { gtk-icon-theme-name = cfg.iconTheme.name; }
    //
    optionalAttrs (notNull cfg.cursorTheme "name")
      { gtk-cursor-theme-name = cfg.cursorTheme.name; }
    //
    optionalAttrs (notNull cfg.cursorTheme "size")
      { gtk-cursor-theme-size = cfg.cursorTheme.size; };

    dconf-settings = with lib.gvariant; {
      "org/gnome/desktop/interface" =
        optionalAttrs (notNull cfg.font "name")
          { font-name = cfg.font.name; }
        //
        optionalAttrs (notNull cfg.monospaceFont "name")
          { monospace-font-name = cfg.monospaceFont.name; }
        //
        optionalAttrs (notNull cfg.theme "name")
          { gtk-theme = cfg.theme.name; }
        //
        optionalAttrs (notNull cfg.iconTheme "name")
          { icon-theme = cfg.iconTheme.name; }
        //
        optionalAttrs (notNull cfg.cursorTheme "name")
          { cursor-theme = cfg.cursorTheme.name; }
        //
        optionalAttrs (notNull cfg.cursorTheme "size")
          { cursor-size = mkInt32 cfg.cursorTheme.size; };
    };

  themeType = types.submodule {
    options = {
      package = mkOption {
        internal = true;
        type = types.nullOr types.package;
        default = null;
      };
      name = mkOption {
        internal = true;
        type = types.nullOr types.str;
        default = null;
      };
      size = mkOption {
        internal = true;
        type = types.nullOr types.int;
      };
    };
  };

  optionalPackage = opt:
    optional (opt != null && opt.package != null) opt.package;
  notNull = opt: attr:
    (opt != null && opt."${attr}" != null);
in
{
  options = {
    gtk = {
      enable = mkEnableOption "Gtk theming configuration";

      disableCsd = mkOption {
        type = types.bool;
        default = true;
      };

      fixDialogs = mkOption {
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

      monospaceFont = mkOption {
        type = types.nullOr themeType;
        default = null;
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
    (mkIf disableCsd {
      environment.variables.GTK_CSD = "0";
      environment.variables.LD_PRELOAD = "${pkgs.nur.repos.dukzcry.gtk3-nocsd}/lib/libgtk3-nocsd.so.0";
    })

    # https://github.com/NixOS/nixpkgs/issues/87667
    (mkIf fixDialogs {
      environment = {
        systemPackages = [
          (pkgs.runCommand "gtk3-schemas" {} ''
            mkdir -p $out/share
            ln -s ${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0 $out/share
          '')
        ];
        pathsToLink = [ "/share/glib-2.0" ];
      };
    })

    (mkIf cfg.enable {
      environment.systemPackages =
        optionalPackage cfg.font
        ++ optionalPackage cfg.monospaceFont
        ++ optionalPackage cfg.theme
        ++ optionalPackage cfg.iconTheme
        ++ optionalPackage cfg.cursorTheme;

      environment.etc."xdg/gtk-2.0/gtkrc".text =
        concatStringsSep "\n" (
          mapAttrsToList toGtk2File settings
        );

      environment.etc."xdg/gtk-3.0/settings.ini".text =
        toGtk3File { Settings = settings; };

      environment.etc."xdg/gtk-4.0/gtk.css".text = gtk4Css;

      programs.dconf.enable = lib.mkDefault true;
      programs.dconf.profiles = {
        user.databases = [
          {
            settings = dconf-settings;
          }
        ];
      };
    })
  ];
}
