{ config, lib, pkgs, ... }:

let
  inherit (config) host;
  inherit (lib.generators) toINI;
  inherit (lib.hm.gvariant) mkTuple;

  palette = import ../resources/palette.nix { inherit lib pkgs; };

  extensions = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.caffeine
    gnomeExtensions.notification-banner-position
    gnomeExtensions.run-or-raise
    gnomeExtensions.system-monitor-next
    gnomeExtensions.tiling-assistant
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

  # Shell
  dconf.settings."org/gnome/desktop/interface".clock-format = "24h";
  dconf.settings."org/gnome/desktop/interface".clock-show-weekday = true;
  dconf.settings."org/gnome/shell".enabled-extensions = map (e: e.extensionUuid) extensions;

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
  dconf.settings."org/gnome/shell/keybindings" = {
    toggle-quick-settings = [ ];
  };
  xdg.configFile."run-or-raise/shortcuts.conf".text = ''
    <Super>c,qalculate-gtk,qalculate-gtk,
    <Super>f,firefox,firefox,
    <Super>n,obsidian,obsidian,
    <Super>t,kitty,kitty,
    <Super>s,codium,VSCodium,
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
