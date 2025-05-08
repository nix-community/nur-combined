{ config, lib, pkgs, ... }:

let
  inherit (builtins) floor head mapAttrs sort toJSON;
  inherit (config) dconf host;
  inherit (config.programs) kitty;
  inherit (lib) getExe;
  inherit (lib.generators) toINI;
  inherit (lib.hm.gvariant) mkTuple;

  palette = import ../resources/palette.nix { inherit lib pkgs; };

  extensions = with pkgs.gnomeExtensions; [
    appindicator
    caffeine
    paperwm
    run-or-raise
    system-monitor-next
    user-themes
  ];
in
{
  # Packages
  home.packages = with pkgs; [
    gnome-tweaks
  ] ++ extensions;

  # Backend
  dconf.settings."org/gnome/mutter".experimental-features = [ "scale-monitor-framebuffer" ]; # Workaround for paperwm/PaperWM#938

  # Theme
  dconf.settings."org/gnome/desktop/interface".accent-color = "orange"; # TODO: Match to palette.orange?
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  dconf.settings."org/gnome/desktop/background".picture-uri = host.background;
  dconf.settings."org/gnome/desktop/background".picture-uri-dark = host.background;
  dconf.settings."org/gnome/desktop/screensaver".picture-uri = host.background;
  dconf.settings."org/gtk/settings/color-chooser".custom-colors = with palette.rgb;
    map ({ r, g, b }: mkTuple [ r g b 1.0 ])
      [ red green yellow blue orange purple ];
  xdg.configFile."paperwm/user.css".text = with palette.cssRgba; ''
    .paperwm-selection {
      background-color: transparent;
      border: ${toString dconf.settings."org/gnome/shell/extensions/paperwm".selection-border-size}px ${black kitty.settings.background_opacity};
    }
  '';

  # Shell
  dconf.settings."org/gnome/desktop/interface".clock-format = "24h";
  dconf.settings."org/gnome/desktop/interface".clock-show-weekday = true;
  dconf.settings."org/gnome/desktop/interface".enable-hot-corners = false;
  dconf.settings."org/gnome/shell".enabled-extensions = map (e: e.extensionUuid) extensions;

  # Disabled extensions notification
  xdg.configFile."autostart/disabled-extensions-notification.desktop".text = toINI { } {
    "Desktop Entry" = {
      Type = "Application";
      Name = "Disabled Extensions Notification";
      NoDisplay = true;
      Exec = pkgs.writeShellScript "disabled-extensions-notification" ''
        [[ "$(gsettings get org.gnome.shell disable-user-extensions)" == 'true' ]] || exit

        case "$(${getExe pkgs.libnotify} --urgency 'critical' --icon 'extensions' \
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
    unmaximize = [ ];
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
    "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
  ];
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
    name = "Activate screensaver";
    command = "dbus-send --session --dest=org.gnome.ScreenSaver --type=method_call '/org/gnome/ScreenSaver' 'org.gnome.ScreenSaver.SetActive' 'boolean:true'";
    binding = "HangupPhone";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
    name = "Emote";
    command = getExe pkgs.emote;
    binding = "Favorites";
  };
  dconf.settings."org/gnome/shell/extensions/paperwm" =
    let
      # Common
      external_display_width = 3840;
      external_display_density = 1.0;

      # Parameters
      characters_per_line = 100 /* Rust */;
      character_width = 7.5;
      border = 4;
      margin = 12;
      browser_width = 992 /* Bootstrap large */;

      # Derived
      gap = border + margin;

      # Reference widths
      full = (host.display_width / host.display_density) - margin * 2;
      externalFull = (external_display_width / external_display_density) - margin * 2;

      # Window widths
      widths = rec {
        term = characters_per_line * character_width;
        half = (full - gap) / 2;
        complementTerm = full - (term + gap);
        externalComplement2Browser =
          let
            candidates = [ term half complementTerm ];
            browser = head (sort
              (a: b:
                if a >= browser_width && b >= browser_width then a < b
                else if a < browser_width && b < browser_width then a > b
                else a >= browser_width
              )
              candidates);
          in
          externalFull - (browser + gap) * 2;
      };
    in
    with mapAttrs (_: floor) widths;
    {
      cycle-width-steps = map (n: 1.0 * n) (sort (a: b: a < b) ([
        term
        half
        (if complementTerm > term then complementTerm else browser_width)
        externalComplement2Browser
      ]));
      horizontal-margin = margin;
      selection-border-radius-top = border;
      selection-border-size = border;
      show-focus-mode-icon = false;
      show-open-position-icon = false;
      show-window-position-bar = false;
      vertical-margin = margin;
      vertical-margin-bottom = margin;
      window-gap = gap;
      winprops = (map toJSON [
        { wm_class = "*"; preferredWidth = "${toString half}px"; }
        { wm_class = "Display"; scratch_layer = true; }
        { wm_class = "displaycal"; scratch_layer = true; }
        { wm_class = "emote"; scratch_layer = true; }
        { wm_class = "firefox"; title = "Picture-in-Picture"; scratch_layer = true; }
        { wm_class = "@joplin/app-desktop"; preferredWidth = "${toString term}px"; }
        { wm_class = "qalculate-gtk"; preferredWidth = "480px"; }
        { wm_class = "Tor Browser"; scratch_layer = true; }
      ]);
    };
  dconf.settings."org/gnome/shell/extensions/paperwm/keybindings" = {
    barf-out = [ "" ];
    barf-out-active = [ "" ];
    center-horizontally = [ "" ];
    close-window = [ "" ];
    cycle-height = [ "<Shift>F15" ];
    cycle-height-backwards = [ "<Shift>F14" ];
    cycle-width = [ "F15" ];
    cycle-width-backwards = [ "F14" ];
    live-alt-tab = [ "" ];
    live-alt-tab-backward = [ "" ];
    live-alt-tab-scratch = [ "" ];
    live-alt-tab-scratch-backward = [ "" ];
    move-left = [ "<Shift><Control><Alt>Page_Up" ];
    move-monitor-above = [ "" ];
    move-monitor-below = [ "" ];
    move-monitor-left = [ "" ];
    move-monitor-right = [ "" ];
    move-previous-workspace = [ "" ];
    move-previous-workspace-backward = [ "" ];
    move-right = [ "<Shift><Control><Alt>Page_Down" ];
    move-space-monitor-above = [ "" ];
    move-space-monitor-below = [ "" ];
    move-space-monitor-left = [ "" ];
    move-space-monitor-right = [ "" ];
    new-window = [ "" ];
    paper-toggle-fullscreen = [ "" ];
    previous-workspace = [ "" ];
    previous-workspace-backward = [ "" ];
    resize-h-dec = [ "" ];
    resize-h-inc = [ "" ];
    resize-w-dec = [ "" ];
    resize-w-inc = [ "" ];
    slurp-in = [ "" ];
    swap-monitor-above = [ "" ];
    swap-monitor-below = [ "" ];
    swap-monitor-left = [ "" ];
    swap-monitor-right = [ "" ];
    switch-first = [ "" ];
    switch-focus-mode = [ "" ];
    switch-last = [ "" ];
    switch-left = [ "<Shift><Alt>Page_Up" ];
    switch-monitor-above = [ "" ];
    switch-monitor-below = [ "" ];
    switch-monitor-left = [ "" ];
    switch-monitor-right = [ "" ];
    switch-next = [ "" ];
    switch-open-window-position = [ "" ];
    switch-previous = [ "" ];
    switch-right = [ "<Shift><Alt>Page_Down" ];
    take-window = [ "<Shift><Alt>space" ];
    toggle-maximize-width = [ "F13" ];
    toggle-scratch = [ "<Control>F14" ];
    toggle-scratch-layer = [ "<Control>F15" ];
    toggle-scratch-window = [ "" ];
    toggle-top-and-position-bar = [ "" ];
  };
  dconf.settings."org/gnome/shell/keybindings" = {
    toggle-quick-settings = [ ];
  };
  xdg.configFile."run-or-raise/shortcuts.conf".text = ''
    XF86NotificationCenter,qalculate-gtk,qalculate-gtk,
    <Super>c,codium,VSCodium,
    <Super>f,firefox,firefox,
    <Super>j,joplin-desktop,@joplin/app-desktop,
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
