{ unstable, ... }:
{
  extpkg = unstable.gnomeExtensions.hotkeys-popup;
  dconf = {
    name = "org/gnome/shell/extensions/hotkeys-popup";
    value = {
      hide-array=[
        "cycle-panels"
        "cycle-windows-backward"
        "panel-main-menu"
        "move-to-monitor-down"
        "move-to-monitor-up"
        "move-to-workspace-down"
        "move-to-workspace-up"
        "move-to-workspace-last"
        "move-to-workspace-left"
        "move-to-workspace-right"
        "switch-panels"
        "switch-panels-backward"
        "switch-group"
        "switch-group-backward"
        "switch-to-workspace-down"
        "switch-to-workspace-up"
        "switch-to-workspace-left"
        "switch-to-workspace-right"
        "cycle-group-backward"
        "cycle-panels-backward"
        "toggle-maximized"
        "toggle-overview"
        "switch-to-workspace-4"
        "move-to-workspace-4"
        "cycle-group"
        "toggle-message-tray"
        "focus-active-notification"
        "activate-window-menu"
        "switch-applications-backward"
        "toggle-application-view"
        "show-screen-recording-ui"
        "screenshot"
        "open-application-menu"
        "shift-overview-up"
        "shift-overview-down"
        "screenshot-window"
        "switch-to-workspace-1"
        "switch-to-workspace-2"
        "move-to-workspace-1"
        "switch-to-workspace-3"
        "move-to-workspace-2"
        "move-to-workspace-3"
      ];

      keybinding-show-popup = [ "<Super><Shift>s" ];
      show-icon = true;
      transparent-popup = true;

    };
  };
}

