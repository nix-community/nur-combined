{ config, lib, pkgs, ... }:

# docs: https://nixos.wiki/wiki/Sway
# sway-config docs: `man 5 sway`
let
  cfg = config.sane.gui.sway;
  wrapSway = sway': swayOverrideArgs: let
    # `wrapSway` exists to create a `sway.desktop` file
    # which will launch sway with our desired debugging facilities.
    # i.e. redirect output to syslog.
    scfg = config.programs.sway;
    systemd-cat = "${pkgs.systemd}/bin/systemd-cat";
    swayWithLogger = pkgs.writeShellScriptBin "sway-session" ''
      echo "launching sway-session (sway.desktop)..." | ${systemd-cat} --identifier=sway-session
      sway 2>&1 | ${systemd-cat} --identifier=sway-session
    '';
    # this override is what `programs.nixos` would do internally if we left `package` unset.
    configuredSway = sway'.override swayOverrideArgs;
    desktop-file = pkgs.runCommand "sway-desktop-wrapper" {} ''
      mkdir -p $out/share/wayland-sessions
      substitute ${configuredSway}/share/wayland-sessions/sway.desktop $out/share/wayland-sessions/sway.desktop \
        --replace 'Exec=sway' 'Exec=${swayWithLogger}/bin/sway-session'
      # XXX(2023/09/24) phog greeter (mobile greeter) will crash if DesktopNames is not set
      echo "DesktopNames=Sway" >> $out/share/wayland-sessions/sway.desktop
    '';
  in pkgs.symlinkJoin {
    inherit (configuredSway) name meta;
    # the order of these `paths` is suchs that the desktop-file should claim share/wayland-sessions/sway.deskop,
    # overriding whatever the configuredSway provides
    paths = [ desktop-file configuredSway ];
    passthru = {
      inherit (configuredSway.passthru) providedSessions;
      # nixos/modules/programs/wayland/sway.nix will call `.override` on the package we provide it
      override = wrapSway sway';
    };
  };
  defaultPackage = wrapSway pkgs.sway {
    # this is technically optional, in that the nixos sway module will call `override` with these args anyway.
    # but that wasn't always the case; it may change again; so don't rely on it.
    inherit (config.programs.sway)
      extraSessionCommands extraOptions;
    withBaseWrapper = config.programs.sway.wrapperFeatures.base;
    withGtkWrapper  = config.programs.sway.wrapperFeatures.gtk;
    isNixOS = true;
      # TODO: `enableXWayland = ...`?
  };
in
{
  options = with lib; {
    sane.gui.sway.enable = mkOption {
      default = false;
      type = types.bool;
    };
    sane.gui.sway.package = mkOption {
      default = defaultPackage;
      type = types.package;
    };
    sane.gui.sway.useGreeter = mkOption {
      description = ''
        launch sway via a greeter (like greetd's gtkgreet).
        sway is usable without a greeter, but skipping the greeter means no PAM session.
      '';
      default = true;
      type = types.bool;
    };
    sane.gui.sway.config = {
      extra_lines = mkOption {
        type = types.lines;
        description = ''
          extra lines to append to the sway config
        '';
        default = ''
          # XXX: sway needs exclusive control of XF86Audio{Raise,Lower}Volume, so assign this from a block that it can override.
          # TODO: factor the bindings out into proper options and be less hacky?
          bindsym --locked XF86AudioRaiseVolume exec $volume_up
          bindsym --locked XF86AudioLowerVolume exec $volume_down
        '';
      };
      background = mkOption {
        type = types.path;
      };
      font = mkOption {
        type = types.str;
        default = "pango:monospace 11";
        description = ''
          default font (for e.g. window titles)
        '';
      };
      mod = mkOption {
        type = types.str;
        default = "Mod4";
        description = ''
          Super key (for non-application shortcuts).
          - "Mod1" for Alt
          - "Mod4" for logo key
        '';
      };
      workspace_layout = mkOption {
        type = types.str;
        default = "default";
        description = ''
          how to arrange windows within new workspaces, by default:
          - "default" (split)
          - "tabbed"
          - etc
        '';
      };
      xwayland = mkOption {
        type = types.bool;
        default = true;
        description = ''
          whether or not to enable xwayland (allows running X11 apps on sway).
          some electron apps (e.g. element-desktop) require xwayland.
        '';
      };

      # TODO: split these into their own option scope
      brightness_down_cmd = mkOption {
        type = types.str;
        default = "${pkgs.brightnessctl}/bin/brightnessctl set 2%-";
        description = "command to run when use wants to decrease screen brightness";
      };
      brightness_up_cmd = mkOption {
        type = types.str;
        default = "${pkgs.brightnessctl}/bin/brightnessctl set +2%";
        description = "command to run when use wants to increase screen brightness";
      };
      screenshot_cmd = mkOption {
        type = types.str;
        default = "${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
        description = "command to run when user wants to take a screenshot";
      };
    };
    sane.gui.sway.waybar.extra_style = mkOption {
      type = types.lines;
      default = ''
        /* default font-size is about 14px, which is good for moby, but not quite for larger displays */
        window#waybar {
          font-size: 16px;
        }
      '';
      description = ''
        extra CSS rules to append to ~/.config/waybar/style.css
      '';
    };
    sane.gui.sway.waybar.top = mkOption {
      type = types.submodule {
        # `attrsOf types.anything` (v.s. plain `attrs`) causes merging of the toplevel items.
        # this allows for `waybar.top.x = lib.mkDefault a;` with `waybar.top.x = b;` to resolve to `b`.
        # but note that `waybar.top.x.y = <multiple assignment>` won't be handled as desired.
        freeformType = types.attrsOf types.anything;
      };
      default = {};
      description = ''
        Waybar configuration for the bar at the top of the display.
        see: <https://github.com/Alexays/Waybar/wiki/Configuration>
        example:
        ```nix
        {
          height = 40;
          modules-left = [ "sway/workspaces" "sway/mode" ];
          ...
        }
        ```
      '';
    };
  };

  config = lib.mkMerge [
    {
      sane.programs.swayApps = {
        package = null;
        suggestedPrograms = [
          "guiApps"
          "conky"  # for a nice background
          "splatmoji"  # used by us, but 'enabling' it gets us persistence & cfg
          "swaylock"
          "swayidle"
          "wl-clipboard"
          "blueberry"  # GUI bluetooth manager
          "playerctl"  # for waybar & particularly to have playerctld running
          # "mako"  # notification daemon
          "swaynotificationcenter"  # notification daemon
          # # "pavucontrol"
          # "gnome.gnome-bluetooth"  # XXX(2023/05/14): broken
          # "gnome.gnome-control-center"  # XXX(2023/06/28): depends on webkitgtk4_1
          "sway-contrib.grimshot"
          "wdisplays"  # like xrandr
        ];

        secrets.".config/sane-sway/snippets.txt" = ../../../../secrets/common/snippets.txt.bin;
      };

      # default waybar
      sane.gui.sway.waybar.top = import ./waybar-top.nix { inherit lib pkgs; };
    }

    (lib.mkIf cfg.enable {
      sane.programs.fontconfig.enableFor.system = true;
      sane.programs.swayApps.enableFor.user.colin = true;

      sane.gui.gtk.enable = lib.mkDefault true;
      # sane.gui.gtk.gtk-theme = lib.mkDefault "Fluent-Light-compact";
      sane.gui.gtk.gtk-theme = lib.mkDefault "Tokyonight-Light-B";
      # sane.gui.gtk.icon-theme = lib.mkDefault "HighContrast";  # 4/5 coverage on moby
      # sane.gui.gtk.icon-theme = lib.mkDefault "WhiteSur";  # 3.5/5 coverage on moby, but it provides a bunch for Fractal/Dino
      # sane.gui.gtk.icon-theme = lib.mkDefault "Humanity";  # 3.5/5 coverage on moby, but it provides the bookmark icon
      # sane.gui.gtk.icon-theme = lib.mkDefault "Paper";  # 3.5/5 coverage on moby, but it provides the bookmark icon
      # sane.gui.gtk.icon-theme = lib.mkDefault "Nordzy";  # 3/5 coverage on moby
      # sane.gui.gtk.icon-theme = lib.mkDefault "Fluent";  # 3/5 coverage on moby
      # sane.gui.gtk.icon-theme = lib.mkDefault "Colloid";  # 3/5 coverage on moby
      # sane.gui.gtk.icon-theme = lib.mkDefault "Qogir";  # 2.5/5 coverage on moby
      # sane.gui.gtk.icon-theme = lib.mkDefault "rose-pine-dawn";  # 2.5/5 coverage on moby
      # sane.gui.gtk.icon-theme = lib.mkDefault "Flat-Remix-Grey-Light";  # requires qtbase

      # swap in these lines to use SDDM instead of `services.greetd`.
      # services.xserver.displayManager.sddm.enable = true;
      # services.xserver.enable = true;
      sane.gui.greetd = lib.mkIf cfg.useGreeter {
        enable = true;
        sway.enable = true;  # have greetd launch a sway compositor in which we host a greeter
        sway.gtkgreet = {
          enable = true;
          session.name = "sway-on-gtkgreet";
          session.command = "${cfg.package}/bin/sway";
        };
      };

      # unlike other DEs, sway configures no audio stack
      # administer with pw-cli, pw-mon, pw-top commands
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;  # ??
        # emulate pulseaudio for legacy apps (e.g. sxmo-utils)
        pulse.enable = true;
      };
      services.gvfs.enable = true;  # allow nautilus to mount remote filesystems (e.g. ftp://...)
      # rtkit/RealtimeKit: allow applications which want realtime audio (e.g. Dino? Pulseaudio server?) to request it.
      # this might require more configuration (e.g. polkit-related) to work exactly as desired.
      # - readme outlines requirements: <https://github.com/heftig/rtkit>
      # XXX(2023/10/12): rtkit does not play well on moby. any application sending audio out dies after 10s.
      # security.rtkit.enable = true;
      # persist per-device volume levels
      sane.user.persist.byStore.plaintext = [ ".local/state/wireplumber" ];

      # persist per-device volume settings across power cycles.
      # pipewire sits atop the kernel ALSA API, so alsa-utils knows about device volumes.
      # but wireplumber also tries to do some of this
      # systemd.services.alsa-store = {
      #   # based on <repo:nixos/nixpkgs:nixos/modules/services/audio/alsa.nix>
      #   description = "Store Sound Card State";
      #   wantedBy = [ "multi-user.target" ];
      #   serviceConfig = {
      #     Type = "oneshot";
      #     RemainAfterExit = true;
      #     ExecStart = "${pkgs.alsa-utils}/sbin/alsactl restore";
      #     ExecStop = "${pkgs.alsa-utils}/sbin/alsactl store --ignore";
      #   };
      # };
      # sane.persist.sys.byStore.plaintext = [ "/var/lib/alsa" ];

      networking.networkmanager.enable = true;
      networking.wireless.enable = lib.mkForce false;

      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
      # gsd provides Rfkill, which is required for the bluetooth pane in gnome-control-center to work
      # services.gnome.gnome-settings-daemon.enable = true;
      # start the components of gsd we need at login
      # systemd.user.targets."org.gnome.SettingsDaemon.Rfkill".wantedBy = [ "graphical-session.target" ];
      # go ahead and `systemctl --user cat gnome-session-initialized.target`. i dare you.
      # the only way i can figure out how to get Rfkill to actually load is to just disable all the shit it depends on.
      # it doesn't actually seem to need ANY of them in the first place T_T
      # systemd.user.targets."gnome-session-initialized".enable = false;
      # bluez can't connect to audio devices unless pipewire is running.
      # a system service can't depend on a user service, so just launch it at graphical-session
      systemd.user.services."pipewire".wantedBy = [ "graphical-session.target" ];

      programs.sway = {
        # provides xdg-desktop-portal-wlr, which exposes on dbus:
        # - org.freedesktop.impl.portal.ScreenCast
        # - org.freedesktop.impl.portal.Screenshot
        enable = true;
        package = cfg.package;
        extraPackages = [];  # nixos adds swaylock, swayidle, foot, dmenu by default
        # extraOptions = [ "--debug" ];
        # "wrapGAppsHook wrapper to execute sway with required environment variables for GTK applications."
        # this literally just sets XDG_DATA_DIRS to the gtk3 gsettings-schemas before launching sway.
        # notably, this pulls in the *build* gtk3 -- probably not in an incompatible way
        # but still as a mistake, and wasteful for cross compilation
        wrapperFeatures.gtk = false;
        # this sets XDG_CURRENT_DESKTOP=sway
        # and makes sure that sway is launched dbus-run-session.
        wrapperFeatures.base = true;
      };
      programs.xwayland.enable = cfg.config.xwayland;
      # provide portals for:
      # - org.freedesktop.impl.portal.Access
      # - org.freedesktop.impl.portal.Account
      # - org.freedesktop.impl.portal.DynamicLauncher
      # - org.freedesktop.impl.portal.Email
      # - org.freedesktop.impl.portal.FileChooser
      # - org.freedesktop.impl.portal.Inhibit
      # - org.freedesktop.impl.portal.Notification
      # - org.freedesktop.impl.portal.Print
      # and conditionally (i.e. unless buildPortalsInGnome = false) for:
      # - org.freedesktop.impl.portal.AppChooser (@appchooser_iface@)
      # - org.freedesktop.impl.portal.Background (@background_iface@)
      # - org.freedesktop.impl.portal.Lockdown (@lockdown_iface@)
      # - org.freedesktop.impl.portal.RemoteDesktop (@remotedesktop_iface@)
      # - org.freedesktop.impl.portal.ScreenCast (@screencast_iface@)
      # - org.freedesktop.impl.portal.Screenshot (@screenshot_iface@)
      # - org.freedesktop.impl.portal.Settings (@settings_iface@)
      # - org.freedesktop.impl.portal.Wallpaper (@wallpaper_iface@)
      xdg.portal.extraPortals = [
        (pkgs.xdg-desktop-portal-gtk.override {
          buildPortalsInGnome = false;
        })
      ];

      sane.user.fs = {
        ".config/waybar/config".symlink.target =
          (pkgs.formats.json {}).generate "waybar-config.json" [
            ({ layer = "top"; } // cfg.waybar.top)
          ];

        ".config/waybar/style.css".symlink.text =
          (builtins.readFile ./waybar-style.css) + cfg.waybar.extra_style;

        ".config/sway/config".symlink.target = import ./sway-config.nix {
            inherit pkgs;
            inherit (cfg) config;
        };
      };
    })
  ];
}

