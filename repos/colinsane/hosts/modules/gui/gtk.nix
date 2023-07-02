# gtk apps search XDG_ICON_DIRS for icons (nixos specific)
# nixos ships the hi-color icon theme by default, which has *some* icons,
# but leaves a lot of standard ones unavailable.
#
# system-wide theme components live in:
# - /run/current-system/sw/share/color-schemes/${theme}
# - /run/current-system/sw/share/icons/${theme}
# - /run/current-system/sw/share/icons/${theme}/cursors  (cursor-theme)
# - /run/current-system/sw/share/themes/${theme}/gtk-4.0
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.gui.gtk;
  unsortedThemes = {
    # crude assortment of themes in nixpkgs; some might not be gtk themes, some gtk themes might not be in this list
    inherit (pkgs)
      # themes are in <repo:nixos/nixpkgs:pkgs/data/themes>
      adapta-gtk-theme
      adapta-kde-theme
      adementary-theme
      adi1090x-plymouth-themes
      adw-gtk3
      adwaita-qt
      adwaita-qt6
      albatross
      amarena-theme
      amber-theme
      ant-bloody-theme
      ant-nebula-theme
      ant-theme
      arc-kde-theme
      arc-theme
      artim-dark
      ayu-theme-gtk
      base16-schemes
      blackbird
      breath-theme
      canta-theme
      catppuccin-gtk
      catppuccin-kde
      catppuccin-kvantum
      catppuccin-plymouth
      clearlooks-phenix
      colloid-gtk-theme
      colloid-kde
      dracula-theme
      e17gtk
      equilux-theme
      flat-remix-gnome
      flat-remix-gtk
      fluent-gtk-theme
      graphite-gtk-theme
      graphite-kde-theme
      greybird
      gruvbox-dark-gtk
      gruvbox-gtk-theme
      gruvterial-theme
      juno-theme
      kde-gruvbox
      kde-rounded-corners
      layan-gtk-theme
      layan-kde
      lightly-boehs
      lightly-qt
      lounge-gtk-theme
      marwaita
      marwaita-manjaro
      marwaita-peppermint
      marwaita-pop_os
      marwaita-ubuntu
      matcha-gtk-theme
      materia-kde-theme
      materia-theme
      material-kwin-decoration
      mojave-gtk-theme
      nixos-bgrt-plymouth
      nordic
      numix-gtk-theme
      numix-solarized-gtk-theme
      numix-sx-gtk-theme
      oceanic-theme
      omni-gtk-theme
      onestepback
      openzone-cursors
      orchis-theme
      orion
      palenight-theme
      paper-gtk-theme
      pitch-black
      plano-theme
      plasma-overdose-kde-theme
      plata-theme
      pop-gtk-theme
      qogir-kde
      qogir-theme
      rose-pine-gtk-theme
      shades-of-gray-theme
      sierra-breeze-enhanced
      sierra-gtk-theme
      skeu
      snowblind
      solarc-gtk-theme
      spacx-gtk-theme
      stilo-themes
      sweet
      sweet-nova
      theme-jade1
      theme-obsidian2
      theme-vertex
      tokyo-night-gtk
      ubuntu-themes
      venta
      vimix-gtk-themes
      whitesur-gtk-theme
      yaru-remix-theme
      yaru-theme
      zuki-themes
    ;
    inherit (pkgs.gnome)
      adwaita-icon-theme
      gnome-themes-extra
    ;
  };

  themes = with pkgs; {
    color-scheme = {
      default = emptyDirectory;
      Dracula = dracula-theme;
      DraculaPurple = dracula-theme;
      Dracula-cursors = dracula-theme;
    };
    cursor-theme = {
      Adwaita = gnome.adwaita-icon-theme;
    };
    gtk-theme = {
      Adwaita = gnome.gnome-themes-extra;  # gtk-3.0
      Adwaita-dark = gnome.gnome-themes-extra;  # gtk-3.0
      Arc = arc-theme;  # gtk-4.0
      Arc-Dark = arc-theme;  # gtk-4.0
      Arc-Darker = arc-theme;  # gtk-4.0
      Arc-Lighter = arc-theme;  # gtk-4.0
      Dracula = dracula-theme;  # gtk-4.0
      E17gtk = e17gtk;  # gtk-3.0
      Fluent = fluent-gtk-theme;  # gtk-4.0
      Fluent-compact = fluent-gtk-theme;  # gtk-4.0
      Fluent-Dark = fluent-gtk-theme;  # gtk-4.0
      Fluent-Dark-compact = fluent-gtk-theme;  # gtk-4.0
      Fluent-Light = fluent-gtk-theme;  # gtk-4.0
      Fluent-Light-compact = fluent-gtk-theme;  # gtk-4.0,  NICE!
      HighContrast = gnome.gnome-themes-extra;  # gtk-3.0
      Matcha-light-azul = matcha-gtk-theme;  # gtk-4.0,  NICE!
      Matcha-light-sea = matcha-gtk-theme;  # gtk-4.0,  NICE!
      # additional Matcha-* omitted
      Nordic = nordic;  # gtk-4.0
      Nordic-bluish-accent = nordic;  # gtk-4.0
      Nordic-darker = nordic;  # gtk-4.0
      Nordic-Polar = nordic;  # gtk-4.0,  NICE
      Numix = numix-gtk-theme;  # gtk-3.20, meh
      NumixSolarizedDarkBlue = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedDarkCyan = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedDarkGreen = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedDarkMagenta = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedDarkOrange = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedDarkRed = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedDarkViolet = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedDarkYellow = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedLightBlue = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedLightBlueDarkTop = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedLightCyan = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedLightGreen = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedLightMagenta = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedLightOrange = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedLightRed = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedLightViolet = numix-solarized-gtk-theme;  # gtk-3.20
      NumixSolarizedLightYellow = numix-solarized-gtk-theme;  # gtk-3.20
      NumixStandard = numix-solarized-gtk-theme;  # gtk-3.20
      Paper = paper-gtk-theme;  # gtk-4.0
      Pop = pop-gtk-theme;  # gtk-4.0
      Pop-dark = pop-gtk-theme;  # gtk-4.0
      Tokyonight-Light-B = tokyo-night-gtk;  # gtk-4.0, NICE
      # other Tokyonight-* omitted
    };
    icon-theme = {
      Adwaita = gnome.adwaita-icon-theme;
      HighContrast = gnome.gnome-themes-extra;  # gtk-3.0
    };
  };
in
{
  options = with lib; {
    sane.gui.gtk.enable = mkOption {
      default = false;
      type = types.bool;
      description = "apply theme to gtk4 apps";
    };
    sane.gui.gtk.all = mkOption {
      default = false;
      type = types.bool;
      description = "install all known gtk themes (for testing)";
    };
    sane.gui.gtk.color-scheme = mkOption {
      default = "default";
      type = types.str;
    };
    sane.gui.gtk.cursor-theme = mkOption {
      default = "Adwaita";
      type = types.str;
    };
    sane.gui.gtk.gtk-theme = mkOption {
      default = "Adwaita";
      type = types.str;
    };
    sane.gui.gtk.icon-theme = mkOption {
      default = "Adwaita";
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.dconf.packages = [
      (pkgs.writeTextFile {
        name = "dconf-sway-settings";
        destination = "/etc/dconf/db/site.d/10_gtk_settings";
        text = ''
          [org/gnome/desktop/interface]
          color-scheme="${cfg.color-scheme}"
          cursor-theme="${cfg.cursor-theme}"
          gtk-theme="${cfg.gtk-theme}"
          icon-theme="${cfg.icon-theme}"
        '';
      })
    ];
    # environment.systemPackages = lib.attrValues themes;
    environment.systemPackages = [
      themes.color-scheme."${cfg.color-scheme}"
      themes.cursor-theme."${cfg.cursor-theme}"
      themes.gtk-theme."${cfg.gtk-theme}"
      themes.icon-theme."${cfg.icon-theme}"
    ] ++ lib.optionals cfg.all (lib.attrValues unsortedThemes);
  };
}
