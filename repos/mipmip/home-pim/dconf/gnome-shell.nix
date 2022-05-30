{ lib, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  dconf.settings = {

    "org/gnome/shell" = {
      disable-user-extensions = false;

      /*
      disabled-extensions = [
        "advanced-alt-tab@G-dH.github.com"
        "clipboard-indicator@tudmotu.com"
        "eclipse@blackjackshellac.ca"
        "hide-panel-for-fullscreen-windows-only@github.freder"
        "nightthemeswitcher@romainvigier.fr"
        "transparent-top-bar@ftpix.com"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
        "places-menu@gnome-shell-extensions.gcampax.github.com"
        "shortcuts2@pimsnel.com"
        "testpim@pimsnel.com"
        "shortcuts@pim"
        "window-list@gnome-shell-extensions.gcampax.github.com"
        "native-window-placement@gnome-shell-extensions.gcampax.github.com"
        "workspaces-bar@fthx"
        "improved-workspace-indicator@michaelaquilina.github.io"
        "worksets@blipk.xyz"
        "dash-to-plank@hardpixel.eu"
        "alwaysshowworkspacethumbnails@alynx.one"
        "forge@jmmaranan.com"
        "extension-list@tu.berry"
        "logomenu@aryan_k"
        "customize-ibus@hollowman.ml"
        "just-perfection-desktop@just-perfection" ];
        */

        /*
        enabled-extensions = [
          "favorites@cvine.org"
          "windowsNavigator@gnome-shell-extensions.gcampax.github.com"
          "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
          "dash-to-panel@jderose9.github.com"
          "espresso@coadmunkee.github.com"
          "GPaste@gnome-shell-extensions.gnome.org"
          "adwaita-theme-switcher@fthx"
          "color-picker@tuberry"
          "hotkeys-popup@pimsnel.com"
          "custom-menu-panel@AndreaBenini"
          "rrc@ogarcia.me"
          "trayIconsReloaded@selfmade.pl"
#          "blur-me@nunchucks"
#          "horizontal-workspace-indicator@tty2.io"
#          "material-shell@papyelgringo"
          #"titlebar-screenshot@jmaargh.github.com"
          #"transparent-top-bar@ftpix.com"
          ];
          */

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

#    "org/gnome/shell/extensions/dash-to-panel" = {
#      animate-appicon-hover-animation-extent = "{'RIPPLE': 4, 'PLANK': 4, 'SIMPLE': 1}";
#      app-ctrl-hotkey-1 = [ "1" ];
#      app-ctrl-hotkey-10 = [ "0" ];
#      app-ctrl-hotkey-2 = [ "2" ];
#      app-ctrl-hotkey-3 = [ "3" ];
#      app-ctrl-hotkey-4 = [ "4" ];
#      app-ctrl-hotkey-5 = [ "5" ];
#      app-ctrl-hotkey-6 = [ "6" ];
#      app-ctrl-hotkey-7 = [ "7" ];
#      app-ctrl-hotkey-8 = [ "8" ];
#      app-ctrl-hotkey-9 = [ "9" ];
#      app-ctrl-hotkey-kp-1 = [ "KP_1" ];
#      app-ctrl-hotkey-kp-10 = [ "KP_0" ];
#      app-ctrl-hotkey-kp-2 = [ "KP_2" ];
#      app-ctrl-hotkey-kp-3 = [ "KP_3" ];
#      app-ctrl-hotkey-kp-4 = [ "KP_4" ];
#      app-ctrl-hotkey-kp-5 = [ "KP_5" ];
#      app-ctrl-hotkey-kp-6 = [ "KP_6" ];
#      app-ctrl-hotkey-kp-7 = [ "KP_7" ];
#      app-ctrl-hotkey-kp-8 = [ "KP_8" ];
#      app-ctrl-hotkey-kp-9 = [ "KP_9" ];
#      app-hotkey-1 = [ "" ];
#      app-hotkey-10 = [ "" ];
#      app-hotkey-2 = [ "" ];
#      app-hotkey-3 = [ "" ];
#      app-hotkey-4 = [ "" ];
#      app-hotkey-5 = [ "" ];
#      app-hotkey-6 = [ "" ];
#      app-hotkey-7 = [ "" ];
#      app-hotkey-8 = [ "" ];
#      app-hotkey-9 = [ "" ];
#      app-hotkey-kp-1 = [ "KP_1" ];
#      app-hotkey-kp-10 = [ "KP_0" ];
#      app-hotkey-kp-2 = [ "KP_2" ];
#      app-hotkey-kp-3 = [ "KP_3" ];
#      app-hotkey-kp-4 = [ "KP_4" ];
#      app-hotkey-kp-5 = [ "KP_5" ];
#      app-hotkey-kp-6 = [ "KP_6" ];
#      app-hotkey-kp-7 = [ "KP_7" ];
#      app-hotkey-kp-8 = [ "KP_8" ];
#      app-hotkey-kp-9 = [ "KP_9" ];
#      app-shift-hotkey-1 = [ "1" ];
#      app-shift-hotkey-10 = [ "0" ];
#      app-shift-hotkey-2 = [ "2" ];
#      app-shift-hotkey-3 = [ "3" ];
#      app-shift-hotkey-4 = [ "4" ];
#      app-shift-hotkey-5 = [ "5" ];
#      app-shift-hotkey-6 = [ "6" ];
#      app-shift-hotkey-7 = [ "7" ];
#      app-shift-hotkey-8 = [ "8" ];
#      app-shift-hotkey-9 = [ "9" ];
#      app-shift-hotkey-kp-1 = [ "KP_1" ];
#      app-shift-hotkey-kp-10 = [ "KP_0" ];
#      app-shift-hotkey-kp-2 = [ "KP_2" ];
#      app-shift-hotkey-kp-3 = [ "KP_3" ];
#      app-shift-hotkey-kp-4 = [ "KP_4" ];
#      app-shift-hotkey-kp-5 = [ "KP_5" ];
#      app-shift-hotkey-kp-6 = [ "KP_6" ];
#      app-shift-hotkey-kp-7 = [ "KP_7" ];
#      app-shift-hotkey-kp-8 = [ "KP_8" ];
#      app-shift-hotkey-kp-9 = [ "KP_9" ];
#      appicon-margin = 2;
#      appicon-padding = 3;
#      available-monitors = [ 0 1 ];
#      desktop-line-custom-color = "rgb(145,65,172)";
#      desktop-line-use-custom-color = true;
#      dot-color-dominant = true;
#      dot-color-override = false;
#      dot-position = "TOP";
#      dot-size = 1;
#      dot-style-focused = "METRO";
#      focus-highlight-dominant = false;
#      group-apps = false;
#      hot-keys = false;
#      hotkey-prefix-text = "";
#      hotkeys-overlay-combo = "TEMPORARILY";
#      intellihide = false;
#      isolate-monitors = true;
#      isolate-workspaces = true;
#      leftbox-padding = -1;
#      middle-click-action = "LAUNCH";
#      panel-anchors = "'{\"0\":\"MIDDLE\",\"1\":\"MIDDLE\"}'";
#      panel-element-positions = "'{\"0\":[{\"element\":\"showAppsButton\",\"visible\":false,\"position\":\"stackedTL\"},{\"element\":\"activitiesButton\",\"visible\":false,\"position\":\"stackedTL\"},{\"element\":\"leftBox\",\"visible\":true,\"position\":\"stackedTL\"},{\"element\":\"taskbar\",\"visible\":true,\"position\":\"stackedTL\"},{\"element\":\"centerBox\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"rightBox\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"dateMenu\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"systemMenu\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"desktopButton\",\"visible\":true,\"position\":\"stackedBR\"}],\"1\":[{\"element\":\"showAppsButton\",\"visible\":false,\"position\":\"stackedTL\"},{\"element\":\"activitiesButton\",\"visible\":false,\"position\":\"stackedTL\"},{\"element\":\"leftBox\",\"visible\":true,\"position\":\"stackedTL\"},{\"element\":\"taskbar\",\"visible\":true,\"position\":\"stackedTL\"},{\"element\":\"centerBox\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"rightBox\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"dateMenu\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"systemMenu\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"desktopButton\",\"visible\":true,\"position\":\"stackedBR\"}]}'";
#      panel-lengths = "'{\"0\":100,\"1\":100}'";
#      panel-positions = "'{\"0\":\"TOP\",\"1\":\"TOP\"}'";
#      panel-sizes = "'{\"0\":29,\"1\":29}'";
#      scroll-icon-action = "NOTHING";
#      scroll-panel-action = "NOTHING";
#      shift-click-action = "MINIMIZE";
#      shift-middle-click-action = "LAUNCH";
#      show-apps-icon-file = "";
#      show-favorites = false;
#      show-showdesktop-hover = true;
#      show-window-previews = false;
#      showdesktop-button-width = 24;
#      status-icon-padding = -1;
#      stockgs-keep-dash = false;
#      stockgs-keep-top-panel = false;
#      trans-gradient-bottom-color = "#000000";
#      trans-gradient-bottom-opacity = 0.4;
#      trans-gradient-top-color = "#1a5fb4";
#      trans-gradient-top-opacity = 0.25;
#      trans-panel-opacity = 0.5;
#      trans-use-custom-bg = true;
#      trans-use-custom-gradient = false;
#      trans-use-custom-opacity = true;
#      tray-padding = 1;
#      window-preview-title-position = "TOP";
#    };

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
      hide-array = [ "cycle-panels" "cycle-windows-backward" "panel-main-menu" "move-to-monitor-down" "move-to-monitor-up" "move-to-workspace-down" "move-to-workspace-up" "move-to-workspace-last" "move-to-workspace-left" "move-to-workspace-right" "switch-panels" "switch-panels-backward" "switch-group" "switch-group-backward" "switch-to-workspace-down" "switch-to-workspace-up" "switch-to-workspace-left" "switch-to-workspace-right" "cycle-group-backward" "cycle-panels-backward" "toggle-maximized" "toggle-overview" "switch-to-workspace-4" "move-to-workspace-4" "cycle-group" "toggle-message-tray" "focus-active-notification" "activate-window-menu" "switch-applications-backward" ];
      keybinding-show-popup = [ "<Super>s" ];
      show-icon = true;
      transparent-popup = true;
    };

    "extensions/just-perfection" = {
      accessibility-menu = true;
      activities-button = true;
      aggregate-menu = true;
      app-menu = true;
      app-menu-icon = true;
      background-menu = true;
      clock-menu = true;
      clock-menu-position = 0;
      dash = true;
      dash-icon-size = 0;
      double-super-to-appgrid = true;
      gesture = true;
      hot-corner = false;
      keyboard-layout = true;
      notification-banner-position = 1;
      osd = true;
      panel = true;
      panel-arrow = true;
      panel-button-padding-size = 0;
      panel-corner-size = 0;
      panel-in-overview = true;
      panel-indicator-padding-size = 0;
      panel-notification-icon = true;
      power-icon = true;
      ripple-box = true;
      search = true;
      show-apps-button = true;
      startup-status = 1;
      theme = false;
      top-panel-position = 0;
      window-demands-attention-focus = false;
      window-picker-icon = true;
      window-preview-caption = true;
      workspace = true;
      workspace-background-corner-size = 0;
      workspace-popup = true;
      workspace-switcher-size = 0;
      workspaces-in-app-grid = true;
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
