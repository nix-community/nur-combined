{ lib, osConfig, ... }:
let
  inherit (lib.hm) gvariant;
  inherit (lib.strings) hasInfix;
  cfg = if hasInfix "darwin" osConfig.nixpkgs.system then {
    dconf.enable = false;
  } else
    with gvariant; {
      dconf = {
        enable = true;
        settings = {
          "org/gnome/desktop/background" = {
            color-shading-type = "solid";
            picture-options = "zoom";
            picture-uri =
              "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.webp";
            picture-uri-dark =
              "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-d.webp";
            primary-color = "#3071AE";
            secondary-color = "#000000";
          };

          "org/gnome/desktop/input-sources" = {
            per-window = false;
            sources = [ (mkTuple [ "xkb" "us" ]) ];
            xkb-options = [ "terminate:ctrl_alt_bksp" "lv3:ralt_switch" ];
          };

          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            font-antialiasing = "grayscale";
            font-hinting = "slight";
            gtk-im-module = "gtk-im-context-simple";
            gtk-theme = "Adwaita-dark";
            icon-theme = "Adwaita";
          };

          "org/gnome/desktop/notifications" = {
            application-children = [
              "gnome-power-panel"
              "firefox"
              "org-keepassxc-keepassxc"
              "signal-desktop"
              "discord"
              "thunderbird"
              "alacritty"
              "org-gnome-nautilus"
              "gnome-network-panel"
              "slack"
              "steam"
              "gnome-control-center"
              "zoom"
              "gimp"
              "com-nextcloud-desktopclient-nextcloud"
            ];
            show-banners = true;
          };

          "org/gnome/desktop/notifications/application/alacritty" = {
            application-id = "Alacritty.desktop";
          };

          "org/gnome/desktop/notifications/application/brave-browser" = {
            application-id = "brave-browser.desktop";
          };

          "org/gnome/desktop/notifications/application/ca-desrt-dconf-editor" =
            {
              application-id = "ca.desrt.dconf-editor.desktop";
            };

          "org/gnome/desktop/notifications/application/codium" = {
            application-id = "codium.desktop";
          };

          "org/gnome/desktop/notifications/application/com-github-iwalton3-jellyfin-media-player" =
            {
              application-id =
                "com.github.iwalton3.jellyfin-media-player.desktop";
            };

          "org/gnome/desktop/notifications/application/com-nextcloud-desktopclient-nextcloud" =
            {
              application-id = "com.nextcloud.desktopclient.nextcloud.desktop";
            };

          "org/gnome/desktop/notifications/application/discord" = {
            application-id = "discord.desktop";
          };

          "org/gnome/desktop/notifications/application/firefox" = {
            application-id = "firefox.desktop";
          };

          "org/gnome/desktop/notifications/application/gimp" = {
            application-id = "gimp.desktop";
          };

          "org/gnome/desktop/notifications/application/gnome-control-center" = {
            application-id = "gnome-control-center.desktop";
          };

          "org/gnome/desktop/notifications/application/gnome-network-panel" = {
            application-id = "gnome-network-panel.desktop";
          };

          "org/gnome/desktop/notifications/application/gnome-power-panel" = {
            application-id = "gnome-power-panel.desktop";
          };

          "org/gnome/desktop/notifications/application/org-gnome-calculator" = {
            application-id = "org.gnome.Calculator.desktop";
          };

          "org/gnome/desktop/notifications/application/org-gnome-console" = {
            application-id = "org.gnome.Console.desktop";
          };

          "org/gnome/desktop/notifications/application/org-gnome-eog" = {
            application-id = "org.gnome.eog.desktop";
          };

          "org/gnome/desktop/notifications/application/org-gnome-evolution-alarm-notify" =
            {
              application-id = "org.gnome.Evolution-alarm-notify.desktop";
            };

          "org/gnome/desktop/notifications/application/org-gnome-fileroller" = {
            application-id = "org.gnome.FileRoller.desktop";
          };

          "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
            application-id = "org.gnome.Nautilus.desktop";
          };

          "org/gnome/desktop/notifications/application/org-gnome-screenshot" = {
            application-id = "org.gnome.Screenshot.desktop";
          };

          "org/gnome/desktop/notifications/application/org-gnome-settings" = {
            application-id = "org.gnome.Settings.desktop";
          };

          "org/gnome/desktop/notifications/application/org-gnome-tweaks" = {
            application-id = "org.gnome.tweaks.desktop";
          };

          "org/gnome/desktop/notifications/application/org-keepassxc-keepassxc" =
            {
              application-id = "org.keepassxc.KeePassXC.desktop";
            };

          "org/gnome/desktop/notifications/application/org-polymc-polymc" = {
            application-id = "org.polymc.PolyMC.desktop";
          };

          "org/gnome/desktop/notifications/application/runelite" = {
            application-id = "RuneLite.desktop";
          };

          "org/gnome/desktop/notifications/application/signal-desktop" = {
            application-id = "signal-desktop.desktop";
          };

          "org/gnome/desktop/notifications/application/slack" = {
            application-id = "slack.desktop";
          };

          "org/gnome/desktop/notifications/application/steam" = {
            application-id = "steam.desktop";
          };

          "org/gnome/desktop/notifications/application/thunderbird" = {
            application-id = "thunderbird.desktop";
          };

          "org/gnome/desktop/notifications/application/zoom" = {
            application-id = "Zoom.desktop";
          };

          "org/gnome/desktop/peripherals/keyboard" = { numlock-state = true; };

          "org/gnome/desktop/peripherals/touchpad" = {
            two-finger-scrolling-enabled = true;
          };

          "org/gnome/desktop/privacy" = { disable-microphone = false; };

          "org/gnome/desktop/screensaver" = {
            color-shading-type = "solid";
            picture-options = "zoom";
            picture-uri =
              "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.webp";
            primary-color = "#3071AE";
            secondary-color = "#000000";
          };

          "org/gnome/desktop/search-providers" = {
            sort-order = [ "org.gnome.Nautilus.desktop" ];
          };

          "org/gnome/desktop/session" = { idle-delay = mkUint32 300; };

          "org/gnome/desktop/sound" = {
            event-sounds = true;
            theme-name = "freedesktop";
          };

          "org/gnome/desktop/wm/preferences" = {
            button-layout = "appmenu:minimize,maximize,close";
          };

          "org/gnome/file-roller/dialogs/extract" = {
            recreate-folders = true;
            skip-newer = false;
          };

          "org/gnome/file-roller/listing" = {
            list-mode = "as-folder";
            name-column-width = 250;
            show-path = false;
            sort-method = "name";
            sort-type = "ascending";
          };

          "org/gnome/file-roller/ui" = {
            sidebar-width = 200;
            window-height = 480;
            window-width = 600;
          };

          "org/gnome/nautilus/preferences" = {
            default-folder-viewer = "icon-view";
            migrated-gtk-settings = true;
            search-filter-time-type = "last_modified";
            search-view = "list-view";
          };

          "org/gnome/settings-daemon/plugins/color" = {
            night-light-enabled = true;
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
            {
              binding = "<Primary><Shift>space";
              command = "rofi -show drun";
              name = "Rofi Launch";
            };

          "org/gnome/settings-daemon/plugins/power" = {
            power-button-action = "suspend";
          };

          "org/gnome/shell" = {
            app-picker-layout =
              "[{'org.gnome.clocks.desktop': <{'position': <0>}>, 'org.gnome.Calculator.desktop': <{'position': <1>}>, 'simple-scan.desktop': <{'position': <2>}>, 'org.gnome.Settings.desktop': <{'position': <3>}>, 'gnome-system-monitor.desktop': <{'position': <4>}>, 'yelp.desktop': <{'position': <5>}>, 'org.gnome.Screenshot.desktop': <{'position': <6>}>, 'org.gnome.font-viewer.desktop': <{'position': <7>}>, 'org.gnome.FileRoller.desktop': <{'position': <8>}>, 'brave-browser.desktop': <{'position': <9>}>, 'org.gnome.Calendar.desktop': <{'position': <10>}>, 'org.gnome.Console.desktop': <{'position': <11>}>, 'ca.desrt.dconf-editor.desktop': <{'position': <12>}>, 'discord.desktop': <{'position': <13>}>, 'org.gnome.baobab.desktop': <{'position': <14>}>, 'org.gnome.DiskUtility.desktop': <{'position': <15>}>, 'org.gnome.Extensions.desktop': <{'position': <16>}>, 'gimp.desktop': <{'position': <17>}>, 'gparted.desktop': <{'position': <18>}>, 'htop.desktop': <{'position': <19>}>, 'org.gnome.eog.desktop': <{'position': <20>}>, 'org.inkscape.Inkscape.desktop': <{'position': <21>}>, 'com.github.iwalton3.jellyfin-media-player.desktop': <{'position': <22>}>, 'org.gnome.Logs.desktop': <{'position': <23>}>}, {'nixos-manual.desktop': <{'position': <0>}>, 'nvidia-settings.desktop': <{'position': <1>}>, 'org.gnome.seahorse.Application.desktop': <{'position': <2>}>, 'org.polymc.PolyMC.desktop': <{'position': <3>}>, 'redshift-gtk.desktop': <{'position': <4>}>, 'steam.desktop': <{'position': <5>}>, 'org.gnome.TextEditor.desktop': <{'position': <6>}>, 'thunderbird.desktop': <{'position': <7>}>, 'org.gnome.tweaks.desktop': <{'position': <8>}>, 'virt-manager.desktop': <{'position': <9>}>, 'xterm.desktop': <{'position': <10>}>, 'Zoom.desktop': <{'position': <11>}>, 'Dota 2.desktop': <{'position': <12>}>, 'com.nextcloud.desktopclient.nextcloud.desktop': <{'position': <13>}>, 'rofi.desktop': <{'position': <14>}>, 'rofi-theme-selector.desktop': <{'position': <15>}>, 'Team Fortress 2.desktop': <{'position': <16>}>}]";
            disable-user-extensions = false;
            disabled-extensions = [
              "user-theme@gnome-shell-extensions.gcampax.github.com"
              "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com"
              "improved-workspace-indicator@michaelaquilina.github.io"
              "apps-menu@gnome-shell-extensions.gcampax.github.com"
              "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
              "places-menu@gnome-shell-extensions.gcampax.github.com"
              "native-window-placement@gnome-shell-extensions.gcampax.github.com"
            ];
            enabled-extensions = [
              "gnome-shell-screenshot@ttll.de"
              "blur-my-shell@aunetx"
              "notification-banner-reloaded@marcinjakubowski.github.com"
              "pop-shell@system76.com"
              "dash-to-panel@jderose9.github.com"
              "caffeine@patapon.info"
              "tailscale-status@maxgallup.github.com"
            ];
            favorite-apps = [
              "Alacritty.desktop"
              "codium.desktop"
              "org.gnome.Nautilus.desktop"
              "firefox.desktop"
              "org.keepassxc.KeePassXC.desktop"
              "signal-desktop.desktop"
              "slack.desktop"
              "RuneLite.desktop"
            ];
            last-selected-power-profile = "performance";
            welcome-dialog-last-shown-version = "40.1";
          };

          "org/gnome/shell/extensions/blur-my-shell" = {
            appfolder-dialog-opacity = 0.51;
            brightness = 0.6;
            dash-opacity = 1.0;
            debug = false;
            hacks-level = 1;
            hidetopbar = false;
            sigma = 30;
          };

          "org/gnome/shell/extensions/caffeine" = {
            indicator-position-max = 3;
            nightlight-control = "never";
            restore-state = true;
            show-indicator = "always";
            toggle-state = true;
            user-enabled = true;
          };

          "org/gnome/shell/extensions/dash-to-panel" = {
            animate-app-switch = false;
            animate-appicon-hover = true;
            animate-appicon-hover-animation-convexity =
              "{'RIPPLE': 2.0, 'PLANK': 1.0}";
            animate-appicon-hover-animation-duration =
              "{'SIMPLE': uint32 160, 'RIPPLE': 130, 'PLANK': 100}";
            animate-appicon-hover-animation-extent =
              "{'RIPPLE': 4, 'PLANK': 4}";
            animate-appicon-hover-animation-rotation =
              "{'SIMPLE': 0, 'RIPPLE': 10, 'PLANK': 0}";
            animate-appicon-hover-animation-travel =
              "{'SIMPLE': 0.29999999999999999, 'RIPPLE': 0.40000000000000002, 'PLANK': 0.0}";
            animate-appicon-hover-animation-type = "PLANK";
            animate-appicon-hover-animation-zoom =
              "{'SIMPLE': 1.0, 'RIPPLE': 1.25, 'PLANK': 2.0}";
            animate-window-launch = false;
            appicon-margin = 8;
            appicon-padding = 6;
            available-monitors = [ 1 0 ];
            dot-position = "BOTTOM";
            dot-style-focused = "DOTS";
            dot-style-unfocused = "DOTS";
            focus-highlight = false;
            focus-highlight-dominant = false;
            group-apps = true;
            hotkeys-overlay-combo = "TEMPORARILY";
            intellihide = true;
            intellihide-animation-time = 50;
            intellihide-behaviour = "ALL_WINDOWS";
            intellihide-close-delay = 100;
            intellihide-enable-start-delay = 500;
            intellihide-hide-from-windows = true;
            intellihide-only-secondary = false;
            intellihide-pressure-threshold = 10;
            intellihide-pressure-time = 200;
            intellihide-show-in-fullscreen = false;
            intellihide-use-pressure = false;
            leftbox-padding = -1;
            panel-anchors = ''
              {"0":"MIDDLE","1":"MIDDLE","2":"MIDDLE"}\n
            '';
            panel-element-positions = ''
              {"0":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":false,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"centered"},{"element":"centerBox","visible":false,"position":"stackedBR"},{"element":"rightBox","visible":false,"position":"stackedBR"},{"element":"dateMenu","visible":false,"position":"stackedBR"},{"element":"systemMenu","visible":false,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}],"1":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":false,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"centered"},{"element":"centerBox","visible":false,"position":"stackedBR"},{"element":"rightBox","visible":false,"position":"stackedBR"},{"element":"dateMenu","visible":false,"position":"stackedBR"},{"element":"systemMenu","visible":false,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}],"2":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":false,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"centered"},{"element":"centerBox","visible":false,"position":"stackedBR"},{"element":"rightBox","visible":false,"position":"stackedBR"},{"element":"dateMenu","visible":false,"position":"stackedBR"},{"element":"systemMenu","visible":false,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}]}\n
            '';
            panel-element-positions-monitors-sync = true;
            panel-lengths = ''
              {"0":100,"1":100,"2":100}\n
            '';
            panel-positions = ''
              {"0":"LEFT","1":"LEFT","2":"LEFT"}\n
            '';
            panel-sizes = ''
              {"0":48,"1":48,"2":48}\n
            '';
            primary-monitor = 1;
            show-appmenu = false;
            show-favorites = true;
            show-favorites-all-monitors = true;
            show-running-apps = true;
            show-tooltip = false;
            show-window-previews = false;
            status-icon-padding = -1;
            stockgs-force-hotcorner = false;
            stockgs-keep-dash = false;
            stockgs-keep-top-panel = true;
            stockgs-panelbtn-click-only = false;
            trans-bg-color = "#000000";
            trans-dynamic-anim-target = 0.0;
            trans-gradient-bottom-opacity = 0.75;
            trans-panel-opacity = 0.0;
            trans-use-custom-bg = false;
            trans-use-custom-gradient = false;
            trans-use-custom-opacity = true;
            trans-use-dynamic-opacity = false;
            tray-padding = -1;
            window-preview-title-position = "TOP";
          };

          "org/gnome/shell/extensions/pop-shell" = {
            active-hint = true;
            gap-inner = mkUint32 2;
            gap-outer = mkUint32 2;
            smart-gaps = true;
            snap-to-grid = true;
            tile-by-default = true;
          };

          "org/gnome/shell/extensions/screenshot" = {
            backend = "gnome-screenshot";
            capture-delay = 0;
            click-action = "show-menu";
            clipboard-action = "none";
            copy-button-action = "set-image-data";
            effect-rescale = 100;
            save-screenshot = true;
          };

          "org/gnome/tweaks" = { show-extensions-notice = false; };

          "org/gtk/gtk4/settings/color-chooser" = {
            selected-color = mkTuple [ true 0.929411768913269 ];
          };

          "org/gtk/gtk4/settings/file-chooser" = {
            date-format = "regular";
            location-mode = "path-bar";
            show-hidden = true;
            show-size-column = true;
            show-type-column = true;
            sidebar-width = 167;
            sort-column = "size";
            sort-directories-first = false;
            sort-order = "descending";
            type-format = "category";
            window-size = mkTuple [ 948 528 ];
          };

          "org/gtk/settings/file-chooser" = {
            date-format = "regular";
            location-mode = "path-bar";
            show-hidden = false;
            show-size-column = true;
            show-type-column = true;
            sidebar-width = 157;
            sort-column = "name";
            sort-directories-first = false;
            sort-order = "ascending";
            type-format = "category";
            window-position = mkTuple [ 1080 410 ];
            window-size = mkTuple [ 1920 1001 ];
          };

          "system/proxy" = { mode = "none"; };
        };
      };
    };
in cfg
