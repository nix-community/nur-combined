{ config, lib, pkgs, sane-lib, ... }:
 
# docs: https://nixos.wiki/wiki/Sway
with lib;
let
  cfg = config.sane.gui.sway;
  # docs: https://github.com/Alexays/Waybar/wiki/Configuration
  # format specifiers: https://fmt.dev/latest/syntax.html#syntax
  waybar-config = [
    { # TOP BAR
      layer = "top";
      height = 40;
      modules-left = ["sway/workspaces" "sway/mode"];
      modules-center = ["sway/window"];
      modules-right = ["custom/mediaplayer" "clock" "battery" "cpu" "network"];
      "sway/window" = {
        max-length = 50;
      };
      # include song artist/title. source: https://www.reddit.com/r/swaywm/comments/ni0vso/waybar_spotify_tracktitle/
      "custom/mediaplayer" = {
        exec = pkgs.writeShellScript "waybar-mediaplayer" ''
          player_status=$(${pkgs.playerctl}/bin/playerctl status 2> /dev/null)
          if [ "$player_status" = "Playing" ]; then
            echo "$(${pkgs.playerctl}/bin/playerctl metadata artist) - $(${pkgs.playerctl}/bin/playerctl metadata title)"
          elif [ "$player_status" = "Paused" ]; then
            echo " $(${pkgs.playerctl}/bin/playerctl metadata artist) - $(${pkgs.playerctl}/bin/playerctl metadata title)"
          fi
        '';
        interval = 2;
        format = "{}  ";
        # return-type = "json";
        on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
        on-scroll-up = "${pkgs.playerctl}/bin/playerctl next";
        on-scroll-down = "${pkgs.playerctl}/bin/playerctl previous";
      };
      network = {
        # docs: https://github.com/Alexays/Waybar/blob/master/man/waybar-network.5.scd
        interval = 2;
        max-length = 40;
        # custom :> format specifier explained here: https://github.com/Alexays/Waybar/pull/472
        format-ethernet = "  {bandwidthUpBits:>}▲ {bandwidthDownBits:>}▼";
        tooltip-format-ethernet = "{ifname} {bandwidthUpBits:>}▲ {bandwidthDownBits:>}▼";

        format-wifi = "{ifname} ({signalStrength}%) {bandwidthUpBits:>}▲ {bandwidthDownBits:>}▼";
        tooltip-format-wifi = "{essid} ({signalStrength}%) {bandwidthUpBits:>}▲ {bandwidthDownBits:>}▼";

        format-disconnected = "";
      };
      cpu = {
        format = " {usage:2}%";
        tooltip = false;
      };
      battery = {
        states = {
          good = 95;
          warning = 30;
          critical = 10;
        };
        format = "{icon} {capacity}%";
        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];
      };
      clock = {
        format-alt = "{:%a, %d. %b  %H:%M}";
      };
    }
  ];
  # waybar-config-text = lib.generators.toJSON {} waybar-config;
  waybar-config-text = (pkgs.formats.json {}).generate "waybar-config.json" waybar-config;

  # bare sway launcher
  sway-launcher = pkgs.writeShellScriptBin "sway-launcher" ''
    ${pkgs.sway}/bin/sway --debug > /tmp/sway.log 2>&1
  '';
  # start sway and have it construct the gtkgreeter
  sway-as-greeter = pkgs.writeShellScriptBin "sway-as-greeter" ''
    ${pkgs.sway}/bin/sway --debug --config ${sway-config-into-gtkgreet} > /tmp/sway-as-greeter.log 2>&1
  '';
  # (config file for the above)
  sway-config-into-gtkgreet = pkgs.writeText "greetd-sway-config" ''
    exec "${gtkgreet-launcher}"
  '';
  # gtkgreet which launches a layered sway instance
  gtkgreet-launcher = pkgs.writeShellScript "gtkgreet-launcher" ''
    # NB: the "command" field here is run in the user's shell.
    # so that command must exist on the specific user's path who is logging in. it doesn't need to exist system-wide.
    ${pkgs.greetd.gtkgreet}/bin/gtkgreet --layer-shell --command sway-launcher
  '';
  greeter-session = {
    # greeter session config
    command = "${sway-as-greeter}/bin/sway-as-greeter";
    # alternatives:
    # - TTY: `command = "${pkgs.greetd.greetd}/bin/agreety --cmd ${pkgs.sway}/bin/sway";`
    # - autologin: `command = "${pkgs.sway}/bin/sway"; user = "colin";`
    # - Dumb Login (doesn't work)": `command = "${pkgs.greetd.dlm}/bin/dlm";`
  };
  greeterless-session = {
    # no greeter
    command = "${sway-launcher}/bin/sway-launcher";
    user = "colin";
  };
in
{
  options = {
    sane.gui.sway.enable = mkOption {
      default = false;
      type = types.bool;
    };
    sane.gui.sway.useGreeter = mkOption {
      description = ''
        launch sway via a greeter (like greetd's gtkgreet).
        sway is usable without a greeter, but skipping the greeter means no PAM session.
      '';
      default = true;
      type = types.bool;
    };
  };
  config = mkMerge [
    {
      sane.programs.swayApps = {
        package = null;
        suggestedPrograms = [
          "guiApps"
          "splatmoji"  # used by us, but 'enabling' it gets us persistence & cfg
          "swaylock"
          "swayidle"
          "wl-clipboard"
          "mako"  # notification daemon
          # # "pavucontrol"
          "gnome.gnome-bluetooth"
          "gnome.gnome-control-center"
          "sway-contrib.grimshot"
        ];
      };
    }
    {
      sane.programs = {
        inherit (pkgs // {
          "gnome.gnome-bluetooth" = pkgs.gnome.gnome-bluetooth;
          "gnome.gnome-control-center" = pkgs.gnome.gnome-control-center;
          "sway-contrib.grimshot" = pkgs.sway-contrib.grimshot;
        })
          swaylock
          swayidle
          wl-clipboard
          mako
          "gnome.gnome-bluetooth"
          "gnome.gnome-control-center"
          "sway-contrib.grimshot"
        ;
      };
    }

    (mkIf cfg.enable {
      sane.programs.swayApps.enableFor.user.colin = true;

      # swap in these lines to use SDDM instead of `services.greetd`.
      # services.xserver.displayManager.sddm.enable = true;
      # services.xserver.enable = true;
      services.greetd = {
        # greetd source/docs:
        # - <https://git.sr.ht/~kennylevinsen/greetd>
        enable = true;
        settings = {
          default_session = if cfg.useGreeter then greeter-session else greeterless-session;
        };
      };
      # we need the greeter's command to be on our PATH
      users.users.colin.packages = [ sway-launcher ];

      # some programs (e.g. fractal) **require** a "Secret Service Provider"
      services.gnome.gnome-keyring.enable = true;

      # unlike other DEs, sway configures no audio stack
      # administer with pw-cli, pw-mon, pw-top commands
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;  # ??
        pulse.enable = true;
      };

      networking.useDHCP = false;
      networking.networkmanager.enable = true;
      networking.wireless.enable = lib.mkForce false;

      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
      # gsd provides Rfkill, which is required for the bluetooth pane in gnome-control-center to work
      services.gnome.gnome-settings-daemon.enable = true;
      # start the components of gsd we need at login
      systemd.user.targets."org.gnome.SettingsDaemon.Rfkill".wantedBy = [ "graphical-session.target" ];
      # go ahead and `systemctl --user cat gnome-session-initialized.target`. i dare you.
      # the only way i can figure out how to get Rfkill to actually load is to just disable all the shit it depends on.
      # it doesn't actually seem to need ANY of them in the first place T_T
      systemd.user.targets."gnome-session-initialized".enable = false;
      # bluez can't connect to audio devices unless pipewire is running.
      # a system service can't depend on a user service, so just launch it at graphical-session
      systemd.user.services."pipewire".wantedBy = [ "graphical-session.target" ];

      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
      };
      sane.user.fs.".config/sway/config" =
        let
          fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
          sed = "${pkgs.gnused}/bin/sed";
          wtype = "${pkgs.wtype}/bin/wtype";
          kitty = "${pkgs.kitty}/bin/kitty";
          launcher-cmd = fuzzel;
          terminal-cmd = kitty;
          lock-cmd = "${pkgs.swaylock}/bin/swaylock --indicator-idle-visible --indicator-radius 100 --indicator-thickness 30";
          vol-up-cmd = "${pkgs.pulsemixer}/bin/pulsemixer --change-volume +5";
          vol-down-cmd = "${pkgs.pulsemixer}/bin/pulsemixer --change-volume -5";
          mute-cmd = "${pkgs.pulsemixer}/bin/pulsemixer --toggle-mute";
          brightness-up-cmd = "${pkgs.brightnessctl}/bin/brightnessctl set +2%";
          brightness-down-cmd = "${pkgs.brightnessctl}/bin/brightnessctl set 2%-";
          screenshot-cmd = "${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
          # "bookmarking"/snippets inspired by Luke Smith:
          # - <https://www.youtube.com/watch?v=d_11QaTlf1I>
          snip-file = ./snippets.txt;
          # TODO: querying sops here breaks encapsulation
          list-snips = "cat ${snip-file} ${config.sops.secrets.snippets.path}";
          strip-comments = "${sed} 's/ #.*$//'";
          snip-cmd = "${wtype} $(${list-snips} | ${fuzzel} -d -i -w 60 | ${strip-comments})";
          # TODO: next splatmoji release should allow `-s none` to disable skin tones
          emoji-cmd = "${pkgs.splatmoji}/bin/splatmoji -s medium-light type";
        in sane-lib.fs.wantedText ''
          ### default font
          font pango:monospace 8

          ### pixel boundary between windows
          default_border pixel 3
          default_floating_border pixel 2
          hide_edge_borders smart

          ### defaults
          focus_wrapping no
          focus_follows_mouse yes
          focus_on_window_activation smart
          mouse_warping output
          workspace_layout default
          workspace_auto_back_and_forth no

          ### default colors (#border #background #text #indicator #childBorder)
          client.focused #4c7899 #285577 #ffffff #2e9ef4 #285577
          client.focused_inactive #333333 #5f676a #ffffff #484e50 #5f676a
          client.unfocused #333333 #222222 #888888 #292d2e #222222
          client.urgent #2f343a #900000 #ffffff #900000 #900000
          client.placeholder #000000 #0c0c0c #ffffff #000000 #0c0c0c
          client.background #ffffff

          ### key bindings
          floating_modifier Mod1
          ## media keys
          bindsym XF86AudioRaiseVolume exec ${vol-up-cmd}
          bindsym XF86AudioLowerVolume exec ${vol-down-cmd}
          bindsym Mod1+Page_Up exec ${vol-up-cmd}
          bindsym Mod1+Page_Down exec ${vol-down-cmd}
          bindsym XF86AudioMute exec ${mute-cmd}
          bindsym XF86MonBrightnessUp exec ${brightness-up-cmd}
          bindsym XF86MonBrightnessDown exec ${brightness-down-cmd}
          ## special functions
          bindsym Mod1+Print exec ${screenshot-cmd}
          bindsym Mod1+l exec ${lock-cmd}
          bindsym Mod1+s exec ${snip-cmd}
          bindsym Mod1+slash exec ${emoji-cmd}
          bindsym Mod1+d exec ${launcher-cmd}
          bindsym Mod1+Return exec ${terminal-cmd}
          bindsym Mod1+Shift+q kill
          bindsym Mod1+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'
          bindsym Mod1+Shift+c reload
          ## layout
          bindsym Mod1+b splith
          bindsym Mod1+v splitv
          bindsym Mod1+f fullscreen toggle
          bindsym Mod1+a focus parent
          bindsym Mod1+w layout tabbed
          bindsym Mod1+e layout toggle split
          bindsym Mod1+Shift+space floating toggle
          bindsym Mod1+space focus mode_toggle
          bindsym Mod1+r mode resize
          ## movement
          bindsym Mod1+Up focus up
          bindsym Mod1+Down focus down
          bindsym Mod1+Left focus left
          bindsym Mod1+Right focus right
          bindsym Mod1+Shift+Up move up
          bindsym Mod1+Shift+Down move down
          bindsym Mod1+Shift+Left move left
          bindsym Mod1+Shift+Right move right
          ## workspaces
          bindsym Mod1+1 workspace number 1
          bindsym Mod1+2 workspace number 2
          bindsym Mod1+3 workspace number 3
          bindsym Mod1+4 workspace number 4
          bindsym Mod1+5 workspace number 5
          bindsym Mod1+6 workspace number 6
          bindsym Mod1+7 workspace number 7
          bindsym Mod1+8 workspace number 8
          bindsym Mod1+9 workspace number 9
          bindsym Mod1+Shift+1 move container to workspace number 1
          bindsym Mod1+Shift+2 move container to workspace number 2
          bindsym Mod1+Shift+3 move container to workspace number 3
          bindsym Mod1+Shift+4 move container to workspace number 4
          bindsym Mod1+Shift+5 move container to workspace number 5
          bindsym Mod1+Shift+6 move container to workspace number 6
          bindsym Mod1+Shift+7 move container to workspace number 7
          bindsym Mod1+Shift+8 move container to workspace number 8
          bindsym Mod1+Shift+9 move container to workspace number 9
          ## "scratchpad" = ??
          bindsym Mod1+Shift+minus move scratchpad
          bindsym Mod1+minus scratchpad show

          ### defaults
          mode "resize" {
            bindsym Down resize grow height 10 px
            bindsym Escape mode default
            bindsym Left resize shrink width 10 px
            bindsym Return mode default
            bindsym Right resize grow width 10 px
            bindsym Up resize shrink height 10 px
            bindsym h resize shrink width 10 px
            bindsym j resize grow height 10 px
            bindsym k resize shrink height 10 px
            bindsym l resize grow width 10 px
          }

          ### lightly modified bars
          bar {
            # TODO: fonts was:
            #   config.fonts.fontconfig.defaultFonts; (monospace ++ emoji)
            font pango:Hack, Font Awesome 6 Free, Twitter Color Emoji 24.000000
            mode dock
            hidden_state hide
            position top
            status_command ${pkgs.i3status}/bin/i3status
            swaybar_command ${pkgs.waybar}/bin/waybar
            workspace_buttons yes
            strip_workspace_numbers no
            tray_output primary
            colors {
              background #000000
              statusline #ffffff
              separator #666666
              #  #border #background #text
              focused_workspace #4c7899 #285577 #ffffff
              active_workspace #333333 #5f676a #ffffff
              inactive_workspace #333333 #222222 #888888
              urgent_workspace #2f343a #900000 #ffffff
              binding_mode #2f343a #900000 #ffffff
          }
          }

          ### displays
          ## DESKTOP
          output "Samsung Electric Company S22C300 0x00007F35" {
          pos 0,0
          res 1920x1080
          }
          output "Goldstar Company Ltd LG ULTRAWIDE 0x00004E94" {
          pos 1920,0
          res 3440x1440
          }

          ## LAPTOP
          # sh/en TV
          output "Pioneer Electronic Corporation VSX-524 0x00000101" {
          pos 0,0
          res 1920x1080
          }
          # internal display
          output "Unknown 0x0637 0x00000000" {
          pos 1920,0
          res 1920x1080
          }
        '';

      sane.user.fs.".config/waybar/config" = sane-lib.fs.wantedSymlinkTo waybar-config-text;

      # style docs: https://github.com/Alexays/Waybar/wiki/Styling
      sane.user.fs.".config/waybar/style.css" = sane-lib.fs.wantedText ''
        * {
          font-family: monospace;
        }

        /* defaults below: https://github.com/Alexays/Waybar/blob/master/resources/style.css */
        window#waybar {
          background-color: rgba(43, 48, 59, 0.5);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: .5s;
        }

        window#waybar.hidden {
          opacity: 0.2;
        }

        /*
        window#waybar.empty {
          background-color: transparent;
        }
        window#waybar.solo {
          background-color: #FFFFFF;
        }
        */

        window#waybar.termite {
          background-color: #3F3F3F;
        }

        window#waybar.chromium {
          background-color: #000000;
          border: none;
        }

        #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          color: #ffffff;
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
          /* Avoid rounded borders under each workspace name */
          border: none;
          border-radius: 0;
        }

        /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
        #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
          box-shadow: inset 0 -3px #ffffff;
        }

        #workspaces button.focused {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
        }

        #workspaces button.urgent {
          background-color: #eb4d4b;
        }

        #mode {
          background-color: #64727D;
          border-bottom: 3px solid #ffffff;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #network,
        #pulseaudio,
        #custom-media,
        #tray,
        #mode,
        #idle_inhibitor,
        #mpd {
          padding: 0 10px;
          color: #ffffff;
        }

        #window,
        #workspaces {
          margin: 0 4px;
        }

        /* If workspaces is the leftmost module, omit left margin */
        .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
        }

        /* If workspaces is the rightmost module, omit right margin */
        .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
        }

        #clock {
          background-color: #64727D;
        }

        #battery {
          background-color: #ffffff;
          color: #000000;
        }

        #battery.charging, #battery.plugged {
          color: #ffffff;
          background-color: #26A65B;
        }

        @keyframes blink {
          to {
            background-color: #ffffff;
            color: #000000;
          }
        }

        #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: #ffffff;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        label:focus {
          background-color: #000000;
        }

        #cpu {
          background-color: #2ecc71;
          color: #000000;
        }

        #memory {
          background-color: #9b59b6;
        }

        #disk {
          background-color: #964B00;
        }

        #backlight {
          background-color: #90b1b1;
        }

        #network {
          background-color: #2980b9;
        }

        #network.disconnected {
          background-color: #f53c3c;
        }

        #pulseaudio {
          background-color: #f1c40f;
          color: #000000;
        }

        #pulseaudio.muted {
          background-color: #90b1b1;
          color: #2a5c45;
        }

        #custom-media {
          background-color: #66cc99;
          color: #2a5c45;
          min-width: 100px;
        }

        #custom-media.custom-spotify {
          background-color: #66cc99;
        }

        #custom-media.custom-vlc {
          background-color: #ffa000;
        }

        #temperature {
          background-color: #f0932b;
        }

        #temperature.critical {
          background-color: #eb4d4b;
        }

        #tray {
          background-color: #2980b9;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
        }

        #idle_inhibitor {
          background-color: #2d3436;
        }

        #idle_inhibitor.activated {
          background-color: #ecf0f1;
          color: #2d3436;
        }

        #mpd {
          background-color: #66cc99;
          color: #2a5c45;
        }

        #mpd.disconnected {
          background-color: #f53c3c;
        }

        #mpd.stopped {
          background-color: #90b1b1;
        }

        #mpd.paused {
          background-color: #51a37a;
        }

        #language {
          background: #00b093;
          color: #740864;
          padding: 0 5px;
          margin: 0 5px;
          min-width: 16px;
        }

        #keyboard-state {
          background: #97e1ad;
          color: #000000;
          padding: 0 0px;
          margin: 0 5px;
          min-width: 16px;
        }

        #keyboard-state > label {
          padding: 0 5px;
        }

        #keyboard-state > label.locked {
          background: rgba(0, 0, 0, 0.2);
        }
      '';
      # style = ''
      #   * {
      #     border: none;
      #     border-radius: 0;
      #     font-family: Source Code Pro;
      #   }
      #   window#waybar {
      #     background: #16191C;
      #     color: #AAB2BF;
      #   }
      #   #workspaces button {
      #     padding: 0 5px;
      #   }
      #   .custom-spotify {
      #     padding: 0 10px;
      #     margin: 0 4px;
      #     background-color: #1DB954;
      #     color: black;
      #   }
      # '';
    })
  ];
}

