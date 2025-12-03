{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.sane-theme.config;
  enabled = config.sane.programs.sane-theme.enabled;
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
    inherit (pkgs)
      adwaita-icon-theme
      gnome-themes-extra
    ;
  };

  themes = with pkgs; {
    background = {
      sane-nixos-bg = sane-backgrounds;
      nix-l-nord-red = nixos-pattern-nord-wallpapers;
      # many other `nix-l-nord-*`, `nix-d-nord-*`
    };
    color-scheme = {
      default = emptyDirectory;
      Dracula = dracula-theme;
      DraculaPurple = dracula-theme;
    };
    cursor-theme = {
      Adwaita = adwaita-icon-theme;
      Banana = banana-cursor;
      Bibata-Modern-Classic = bibata-cursors;
      # more Bibata cursors exist
      Borealis-cursors = borealis-cursors;
      BreezeX-RosePine-Linux = rose-pine-cursor;
      BreezeX-RosePineDawn-Linux = rose-pine-cursor;
      "Capitaine Cursors" = capitaine-cursors;
      # more Capitaine cursors exist
      ComixCursors-Black = comixcursors.black;
      # more ComixCursors-* cursors exist
      Dracula-cursors = dracula-theme;
      everforest-cursors = everforest-cursors;
      everforest-cursors-light = everforest-cursors;
      Fuchsia = fuchsia-cursor;
      GoogleDot-Black = google-cursor;
      # more GoogleDot-* cursors exist
      graphite-light = graphite-cursors;
      # more graphite-* cursors exist
      layan-cursors = layan-cursors;
      Maple = maplestory-cursor;
      NightDiamond-Blue = nightdiamond-cursors;
      NightDiamond-Red = nightdiamond-cursors;
      Nordzy-catppuccin-latte-light = nordzy-cursor-theme;
      # more Nordzy-catppuccin-* cursors exist
      OpenZone_Black = openzone-cursors;
      # more OpenZone_* cursors exist
      oreo_black_cursors = oreo-cursors-plus;
      # more oreo_*_cursors exist
      phinger-cursors-dark = phinger-cursors;
      phinger-cursors-dark-left = phinger-cursors;
      phinger-cursors-light = phinger-cursors;
      phinger-cursors-light-left = phinger-cursors;
      Plasma-Overdose = plasma-overdose-kde-theme;
      Pokemon = pokemon-cursor;
      Quintom_Ink = quintom-cursor-theme;
      Quintom_Snow = quintom-cursor-theme;
      Simp1e = simp1e-cursors;
      Simp1e-Adw = simp1e-cursors;
      # more Simp1e cursors exist
      Sweet-cursors = sweet-nova;
      WhiteSur-cursors = whitesur-cursors;
      XCursor-Pro-Light = xcursor-pro;
      # more XCursor-Pro cursors exist.
    };
    gtk-theme = {
      Adwaita = gnome-themes-extra;  # gtk-3.0
      Adwaita-dark = gnome-themes-extra;  # gtk-3.0
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
      HighContrast = gnome-themes-extra;  # gtk-3.0
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
      # find icon themes via `nix-locate share/icons/Adwaita`
      # then determine the name here by building and `ls result/share/icons`
      # this misses quite a few icon themes that aren't Adwaita-based.
      # for those, try `nix-locate share/icons`?
      #
      # note that adwaita apps expect exactly the icon set provided by adwaita-icon-theme:
      # - most icon themes are supplementary to adwaita, rather than a full replacement.
      # - i.e. most themes, unless adwaita is also installed, will cause some missing icons inside apps.
      # - that's probably why so many themes here also symlink Adwaita
      # my accounting of "adwaita coverage" seems to be overoptimistic somehow
      # maybe some apps bundle adwaita themselves
      Adwaita = adwaita-icon-theme;
      Arc = arc-icon-theme;  # 4.5/5, meh icon for "vertical ellipsis". 3/5 adwaita coverage
      elementary-xfce = elementary-xfce-icon-theme;  # does not cross compile (2023/10/03)
      elementary-xfce-dark = elementary-xfce-icon-theme;
      elementary-xfce-darker = elementary-xfce-icon-theme;
      elementary-xfce-darkest = elementary-xfce-icon-theme;
      HighContrast = gnome-themes-extra;  # 5/5. 5/5 adwaita coverage (4/5 cross)
      Humanity = humanity-icon-theme;  # 5/5. 5/5 adwaita coverage (3.5/5 cross, unique in which icons work)
      Humanity-Dark = humanity-icon-theme;
      kora = kora-icon-theme;
      kora-light = kora-icon-theme;
      kora-light-panel = kora-icon-theme;
      kora-pgrey = kora-icon-theme;
      Numix = numix-icon-theme;  # 4/5, meh icon for "back".
      Numix-Light = numix-icon-theme;
      Paper = paper-icon-theme;  # 4/5, weird icon for "info". 5/5 adwaita coverage (3.5 cross, highly unique in which icons work)
      Paper-Mono-Dark = paper-icon-theme;
      Pop = pop-icon-theme;  # 5/5. 2/5 adwaita coverage
      Tela-circle = tela-circle-icon-theme;
      Tela-circle-dark = tela-circle-icon-theme;
      Tela-circle-light = tela-circle-icon-theme;

      # themes which don't symlink Adwaita
      BeautyLine = beauty-line-icon-theme;  # 3.5/5. 4/5 adwaita coverage
      breeze = breeze-icons;
      breeze-dark = breeze-icons;
      Mint-X = cinnamon.mint-x-icons;
      # 10-ish other Mint-X variants omitted
      # cinnamon.mint-l-icons;
      # cinnamon.mint-y-icons;
      Colloid = colloid-icon-theme;  # 4.5/5, thin. 5/5 adwaita coverage (3/5 cross)
      Colloid-dark = colloid-icon-theme;
      Colloid-light = colloid-icon-theme;
      bloom = deepin.deepin-icon-theme;
      # 4 other deepin editions omitted
      Dracula = dracula-icon-theme;  # 4.5/5, a little thin. 4.5/5 adwaita coverage
      Faba = faba-icon-theme;  # 4/5. 4/5 adwaita coverage
      Faba-Mono = faba-mono-icons;
      Faba-Mono-Dark = faba-mono-icons;
      Flat-Remix-Grey-Light = flat-remix-icon-theme;  # 5/5. 5/5 adwaita coverage. builds on breeze, elementary
      # 20-ish other flat-remix editions omitted
      Fluent = fluent-icon-theme;  # 5/5, though thin. 5/5 adwaita coverage (3/5 cross)
      Fluent-dark = fluent-icon-theme;
      gnome = gnome-icon-theme;  # 3/5, icons are colored. 3/5 adwaita coverage
      hicolor = hicolor-icon-theme;  # 2/5 adwaita coverage; using this forces application builtin icons
      la-capitaine-icon-theme = la-capitaine-icon-theme;  # 4.5/5. 4.5/5 adwaita coverage. builds upon elementary
      Luna = luna-icons;
      # 5 other Luna variants omitted
      maia = maia-icon-theme;  # 3/5, icons are colored. 2/5 adwaita coverage
      maia-dark = maia-icon-theme;
      # mate.mate-icon-theme-faenza
      mate = mate.mate-icon-theme;  # 4.5/5. 4/5 adwaita coverage
      menta = mate.mate-icon-theme;
      Moka = moka-icon-theme;  # 3/5, icons are colored. 3/5 adwaita coverage
      # nixos-icons;
      Nordzy = nordzy-icon-theme;  # 5/5, thin. 5/5 adwaita coverage (3/5 cross)
      # 10-ish Nordzy editions omitted
      # numix-icon-theme-circle
      # numix-icon-theme-square
      oomox-gruvbox-dark = gruvbox-dark-icons-gtk;
      Oranchelo = oranchelo-icon-theme;
      # 3 other oranchelo editions omitted
      elementary = pantheon.elementary-icon-theme;  # 4.5/5. 4.5/5 adwaita coverage
      Papirus = papirus-icon-theme;  # 5/5. 5/5 adwaita coverage
      # 4 other Papirus editions omitted
      # papirus-maia-icon-theme
      Qogir = qogir-icon-theme;  # 5/5, thin. 5/5 adwaita coverage (2.5/5 cross)
      # 5 other Qogir variants omitted
      rose-pine = rose-pine-icon-theme;
      rose-pine-dawn = rose-pine-icon-theme;  # 5/5. 5/5 adwaita coverage (2.5 cross). looks a lot like Flat Remix...
      rose-pine-moon = rose-pine-icon-theme;
      SuperTinyIcons = super-tiny-icons;  # 4/5. 2/5 adwaita coverage
      Tango = tango-icon-theme;  # 2/5. 3/5 adwaita coverage -- mostly just forwards to gnome-icon-theme
      Tela = tela-icon-theme;  # 5/5. 5/5 adwaita coverage
      # 30-ish other Tela editions omitted
      Vimix = vimix-icon-theme;
      # 15-ish other Vimix editions omitted
      WhiteSur = whitesur-icon-theme;  # 4.5/5, thin & like iOS. 5/5 adwaita coverage (3.5/5 cross)
      WhiteSur-dark = whitesur-icon-theme;
      Rodent = xfce.xfce4-icon-theme;
      Zafiro-icons-Dark = zafiro-icons;
      Zafiro-icons-Light = zafiro-icons;  # 5/5. 5/5 adwaita coverage
    };
  };
in
{
  sane.programs.sane-theme = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options = {
          all = mkOption {
            default = false;
            type = types.bool;
            description = "install all known gtk themes (for testing)";
          };
          background = mkOption {
            default = "nix-l-nord-red";
            type = types.str;
          };
          color-scheme = mkOption {
            default = "default";
            type = types.str;
          };
          cursor-size = mkOption {
            default = 40;
            type = types.int;
          };
          cursor-theme = mkOption {
            default = "Adwaita";
            type = types.str;
          };
          gtk-theme = mkOption {
            default = "Adwaita";
            type = types.str;
          };
          icon-theme = mkOption {
            default = "Adwaita";
            type = types.str;
          };
        };
      };
    };
    packageUnwrapped = pkgs.symlinkJoin {
      name = "sane-theme";
      paths = [
        themes.background."${cfg.background}"
        themes.color-scheme."${cfg.color-scheme}"
        themes.cursor-theme."${cfg.cursor-theme}"
        themes.gtk-theme."${cfg.gtk-theme}"
        themes.icon-theme."${cfg.icon-theme}"
      ] ++ lib.optionals cfg.all (lib.attrValues unsortedThemes);
    };
    sandbox.enable = false;  #< no binaries

    gsettings."org/gnome/desktop/interface" = {
      inherit (cfg) color-scheme cursor-theme gtk-theme icon-theme;
      cursor-size = lib.gvariant.mkInt32 cfg.cursor-size;
    };
  };

  environment.pathsToLink = lib.mkIf enabled [
    "/share/backgrounds"
  ];
}
