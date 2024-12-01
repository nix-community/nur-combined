{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.theme;
  toGtk2File = key: value:
    let
      value' =
        if isString value then "\"${value}\""
        else toString value;
    in
      "${key} = ${value'}";
  toGtk3File = generators.toINI {
    mkKeyValue = key: value: "${key}=${toString value}";
  };
  toSettings = x: mapAttrs' (n: v: nameValuePair
    (if n == "gtk-theme" then
      "gtk-theme-name"
    else if n == "icon-theme" then
      "gtk-icon-theme-name"
    else if n == "cursor-theme" then
      "gtk-cursor-theme-name"
    else if n == "font-name" then
      "gtk-font-name"
    else if n == "cursor-size" then
      "gtk-cursor-theme-size"
    else
      n)
    v) x;
  settings = {
    gtk-theme = cfg.theme;
    icon-theme = cfg.iconTheme;
    cursor-theme = cfg.cursorTheme;
    font-name = cfg.font;
    cursor-size = gvariant.mkInt32 cfg.cursorSize;
  };
in
{
  options.theme = {
    enable = mkEnableOption "uniform look for Qt and GTK applications";
    theme = mkOption {
      type = types.str;
      default = "Adwaita";
    };
    kvantumTheme = mkOption {
      type = types.str;
    };
    iconTheme = mkOption {
      type = types.str;
      default = "Adwaita";
    };
    cursorTheme = mkOption {
      type = types.str;
      default = "Adwaita";
    };
    font = mkOption {
      type = types.str;
      default = "Cantarell 11";
    };
    cursorSize = mkOption {
      type = types.int;
      default = 24;
    };
    platform = mkOption {
      type = types.enum [ "gtk2" "gtk3" "kvantum" ];
      default = "gtk3";
    };
    extraPackages = mkOption {
      type = with types; listOf package;
      default = [];
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.dconf.enable = mkDefault true;
      environment.systemPackages = cfg.extraPackages;
      environment.etc."xdg/gtk-2.0/gtkrc".text =
        concatStringsSep "\n" (
          mapAttrsToList toGtk2File (toSettings settings)
        );
      programs.dconf.profiles.user.databases = [{
        settings."org/gnome/desktop/interface" = settings;
      }];
      environment.etc."xdg/gtk-3.0/settings.ini".text = toGtk3File {
        Settings = toSettings settings;
      };
      environment.etc."xdg/gtk-4.0/gtk.css".text = ''
        @import url("file:///run/current-system/sw/share/themes/${cfg.theme}/gtk-4.0/gtk.css");
      '';
    })
    (mkIf (cfg.enable && cfg.platform == "gtk2") {
      environment.variables = {
        QT_QPA_PLATFORMTHEME = "gtk2";
        QT_STYLE_OVERRIDE = "gtk2";
      };
      environment.systemPackages = with pkgs; [ libsForQt5.qtstyleplugins qt6Packages.qt6gtk2 ];
    })
    (mkIf (cfg.enable && (cfg.platform == "gtk3" || cfg.platform == "kvantum")) {
      environment.variables = {
        QT_QPA_PLATFORMTHEME = "gtk3";
        QT_STYLE_OVERRIDE = if cfg.platform == "kvantum" then "kvantum" else cfg.theme;
      };
      environment.systemPackages = [
        (pkgs.runCommand "gtk3-schemas" {} ''
          mkdir -p $out/share
          ln -s ${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0 $out/share
        '')
      ];
      environment.pathsToLink = [ "/share/glib-2.0" ];
      programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
    })
    (mkIf (cfg.enable && cfg.platform == "kvantum") {
      environment.etc."xdg/Kvantum/kvantum.kvconfig".text = ''
        theme=${cfg.kvantumTheme}
      '';
      environment.systemPackages = with pkgs; [ libsForQt5.qtstyleplugin-kvantum qt6Packages.qtstyleplugin-kvantum ];
      environment.pathsToLink = [ "/share/Kvantum" ];
    })
  ];
}
