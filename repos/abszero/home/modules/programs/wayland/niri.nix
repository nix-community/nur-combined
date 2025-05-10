{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.niri;
in

{
  options.abszero.programs.niri.enable = mkEnableOption "scrolling wayland compositor";

  config.programs.niri = mkIf cfg.enable {
    package = pkgs.niri-unstable;
    settings = {
      clipboard.disable-primary = true; # Disable the clipboard containing last mouse selection
      hotkey-overlay.skip-at-startup = true;
      prefer-no-csd = true;
      screenshot-path = "~/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S.png";

      input = {
        keyboard = {
          repeat-delay = 200;
          repeat-rate = 50;
        };
        touchpad = {
          dwt = true;
          drag-lock = true;
        };
      };

      binds = with config.lib.niri.actions; {
        "Mod+q".action = quit;
        "Mod+Escape".action = toggle-keyboard-shortcuts-inhibit;
        "Mod+o".action = toggle-overview;
        "Mod+k".action = show-hotkey-overlay;

        # Navigation
        "Mod+Space".action = switch-focus-between-floating-and-tiling;
        "Mod+Tab".action = focus-window-previous;

        "Mod+n".action = focus-column-left;
        "Mod+e".action = focus-window-or-workspace-down;
        "Mod+i".action = focus-window-or-workspace-up;
        "Mod+a".action = focus-column-right;
        "Mod+h".action = focus-column-first;
        "Mod+slash".action = focus-monitor-previous;
        "Mod+comma".action = focus-monitor-next;
        "Mod+period".action = focus-column-last;

        # Movement
        "Mod+w".action = close-window;
        "Mod+f".action = fullscreen-window;
        "Mod+m".action = maximize-column;
        "Mod+Shift+Space".action = toggle-window-floating;
        "Mod+t".action = toggle-column-tabbed-display;
        "Mod+u".action = consume-window-into-column;
        "Mod+x".action = expel-window-from-column;

        "Mod+Shift+n".action = move-column-left;
        "Mod+Shift+e".action = move-window-down-or-to-workspace-down;
        "Mod+Shift+i".action = move-window-up-or-to-workspace-up;
        "Mod+Shift+a".action = move-column-right;

        # Media
        XF86AudioMute = {
          action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
          allow-when-locked = true;
        };
        XF86AudioLowerVolume = {
          action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-";
          allow-when-locked = true;
        };
        XF86AudioRaiseVolume = {
          action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+";
          allow-when-locked = true;
        };
        XF86AudioMicMute = {
          action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
          allow-when-locked = true;
        };
        Print.action = screenshot;
        "Shift+Print".action = screenshot-window;
      };
    };
  };
}
