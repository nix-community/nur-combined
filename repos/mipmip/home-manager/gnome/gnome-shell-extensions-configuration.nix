{ lib, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  dconf.settings = {

    "org/gnome/shell" = {
      disable-user-extensions = false;

      favorite-apps = [
        "nemo.desktop"
        "org.gnome.Evolution.desktop"
        "firefox.desktop"
        "Alacritty.desktop"
        "virtualbox.desktop"
        "org.gnome.Calendar.desktop"
        "org.inkscape.Inkscape.desktop" ];
    };

    "org/gnome/shell/extensions/color-picker" = {
      color-picker-shortcut = [ "<Super>l" ];
      enable-shortcut = false;
    };

    "extensions/favorites" = {
      icon = true;
      position = 1;
    };

    "org/gnome/shell/extensions/forge" = {
      focus-border-toggle = false;
      tiling-mode-enabled = true;
      window-gap-hidden-on-single = false;
      window-gap-size = "uint32 8";
      window-gap-size-increment = "uint32 1";
      workspace-skip-tile = "3";
    };

    "org/gnome/shell/extensions/hotkeys-popup" = {

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

    "org/gnome/shell/extensions/trayIconsReloaded" = {
      icon-brightness = -10;
      icon-contrast = 0;
      icon-margin-horizontal = 1;
      icon-padding-horizontal = 1;
      icon-saturation = 0;
      icons-limit = 7;
      position-weight = 2;
      tray-margin-left = 0;
      wine-behavior = false;
    };

    "org/gnome/shell/extensions/search-light" = {
      #background-color = (0.075 0.25 0.068 0.68);
      blur-background = false;
      blur-brightness = 0.6;
      blur-sigma = 30.0;
      border-radius = 1.22;
      border-thickness = 1;
      entry-font-size = 1;
      monitor-count = 1;
      scale-height = 0.3;
      scale-width = 0.19;
      show-panel-icon = false;
      shortcut-search=[ "<Super>space" ];
#      text-color = [1.0 1.0 1.0 0.47];
    };


    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [];
      switch-to-application-2 = [];
      switch-to-application-3 = [];
      switch-to-application-4 = [];
      switch-to-application-5 = [];
      switch-to-application-6 = [];
      switch-to-application-7 = [];
      switch-to-application-8 = [];
      switch-to-application-9 = [];
      toggle-application-view = [ "" ];
      toggle-overview = [ "" ];
    };



  };
}

