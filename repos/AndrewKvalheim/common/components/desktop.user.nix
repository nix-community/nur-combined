{ config, lib, pkgs, ... }:

let
  inherit (config) host;
  inherit (lib.generators) toINI;
  inherit (lib.hm.gvariant) mkTuple mkUint32;

  palette = import ../resources/palette.nix { inherit lib pkgs; };

  extensions = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.caffeine
    gnomeExtensions.forge
    gnomeExtensions.notification-banner-position
    gnomeExtensions.run-or-raise
    gnomeExtensions.system-monitor-next
    gnomeExtensions.user-themes
  ];
in
{
  # Packages
  home.packages = with pkgs; [
    gnome.gnome-tweaks
    yaru-theme
  ] ++ extensions;

  # Theme
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  dconf.settings."org/gnome/desktop/interface".cursor-theme = "Yaru";
  dconf.settings."org/gnome/desktop/interface".gtk-theme = "Yaru-dark";
  dconf.settings."org/gnome/desktop/interface".icon-theme = "Yaru-dark";
  dconf.settings."org/gnome/shell/extensions/user-theme".name = "Yaru-dark";
  dconf.settings."org/gnome/desktop/background".picture-uri = host.background;
  dconf.settings."org/gnome/desktop/background".picture-uri-dark = host.background;
  dconf.settings."org/gnome/desktop/screensaver".picture-uri = host.background;
  dconf.settings."org/gtk/settings/color-chooser".custom-colors = with palette.rgb;
    map ({ r, g, b }: mkTuple [ r g b 1.0 ])
      [ red green yellow blue orange purple ];
  xdg.configFile."forge/stylesheet/forge/stylesheet.css".source = ../resources/forge.css;

  # Shell
  dconf.settings."org/gnome/desktop/interface".clock-format = "24h";
  dconf.settings."org/gnome/desktop/interface".clock-show-weekday = true;
  dconf.settings."org/gnome/desktop/interface".enable-hot-corners = false;
  dconf.settings."org/gnome/shell".enabled-extensions = map (e: e.extensionUuid) extensions;
  dconf.settings."org/gnome/shell/extensions/forge" = {
    auto-split-enabled = false;
    float-always-on-top-enabled = false;
    focus-border-toggle = false;
    move-pointer-focus-enabled = false;
    window-gap-size = mkUint32 0;
  };

  # Disabled extensions notification
  xdg.configFile."autostart/disabled-extensions-notification.desktop".text = toINI { } {
    "Desktop Entry" = {
      Type = "Application";
      Name = "Disabled Extensions Notification";
      NoDisplay = true;
      Exec = pkgs.writeShellScript "disabled-extensions-notification" ''
        [[ "$(gsettings get org.gnome.shell disable-user-extensions)" == 'true' ]] || exit

        case "$(${pkgs.libnotify}/bin/notify-send --urgency 'critical' --icon 'extensions' \
          'Extensions have been automatically disabled.' \
          --action 'enable=Re-Enable' \
          --action 'settings=Settings…')" \
        in
          'enable') gsettings set org.gnome.shell disable-user-extensions 'false';;
          'settings') gnome-extensions-app & disown;;
        esac
      '';
    };
  };

  # Keyboard shortcuts
  dconf.settings."org/gnome/desktop/wm/keybindings" = {
    move-to-monitor-down = [ ];
    move-to-monitor-up = [ ];
    switch-applications = [ ];
    switch-applications-backward = [ ];
    switch-windows = [ "<Alt>Tab" ];
    switch-windows-backward = [ "<Shift><Alt>Tab" ];
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
  ];
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
    name = "Activate screensaver";
    command = "dbus-send --session --dest=org.gnome.ScreenSaver --type=method_call '/org/gnome/ScreenSaver' 'org.gnome.ScreenSaver.SetActive' 'boolean:true'";
    binding = "Favorites";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
    name = "Emote";
    command = "${pkgs.emote}/bin/emote";
    binding = "XF86Messenger";
  };
  dconf.settings."org/gnome/shell/extensions/forge/keybindings" = {
    con-split-horizontal = [ ];
    con-split-layout-toggle = [ ];
    con-split-vertical = [ ];
    con-stacked-layout-toggle = [ ];
    con-tabbed-layout-toggle = [ ];
    con-tabbed-showtab-decoration-toggle = [ ];
    focus-border-toggle = [ ];
    prefs-open = [ ];
    prefs-tiling-toggle = [ ];
    window-focus-down = [ "<Super>Down" ];
    window-focus-left = [ "<Shift><Alt>Page_Up" ];
    window-focus-right = [ "<Shift><Alt>Page_Down" ];
    window-focus-up = [ "<Super>Up" ];
    window-gap-size-decrease = [ ];
    window-gap-size-increase = [ ];
    window-move-down = [ "<Control><Super>Down" ];
    window-move-left = [ "<Shift><Control><Alt>Page_Up" ];
    window-move-right = [ "<Shift><Control><Alt>Page_Down" ];
    window-move-up = [ "<Control><Super>Up" ];
    window-resize-bottom-decrease = [ ];
    window-resize-bottom-increase = [ ];
    window-resize-left-decrease = [ ];
    window-resize-left-increase = [ ];
    window-resize-right-decrease = [ ];
    window-resize-right-increase = [ ];
    window-resize-top-decrease = [ ];
    window-resize-top-increase = [ ];
    window-snap-center = [ ];
    window-snap-one-third-left = [ ];
    window-snap-one-third-right = [ ];
    window-snap-two-third-left = [ ];
    window-snap-two-third-right = [ ];
    window-swap-down = [ ];
    window-swap-last-active = [ ];
    window-swap-left = [ ];
    window-swap-right = [ ];
    window-swap-up = [ ];
    window-toggle-always-float = [ "<Super>F11" ];
    window-toggle-float = [ ];
    workspace-active-tile-toggle = [ ];
  };
  dconf.settings."org/gnome/shell/keybindings" = {
    toggle-quick-settings = [ ];
  };
  xdg.configFile."run-or-raise/shortcuts.conf".text = ''
    XF86Go,qalculate-gtk,qalculate-gtk,
    <Super>c,codium,VSCodium,
    <Super>f,firefox,firefox,
    <Super>n,obsidian,obsidian,
    <Super>t,kitty,kitty,
  '';

  # Window management
  dconf.settings."org/gnome/mutter".attach-modal-dialogs = false;

  # System monitor
  dconf.settings."org/gnome/shell/extensions/system-monitor" = {
    cpu-display = true;
    cpu-graph-width = 60;
    cpu-refresh-time = 2000;
    cpu-show-text = false;
    freq-display = false;
    icon-display = false;
    memory-display = false;
    net-display = false;
    thermal-display = false;
  } // (
    let foreground = "#f2f2f2ff"; muted = "#333333ff"; transparent = "#00000000"; in {
      background = transparent;
      cpu-nice-color = muted;
      cpu-other-color = muted;
      cpu-iowait-color = foreground;
      cpu-system-color = foreground;
      cpu-user-color = foreground;
    }
  );
}
