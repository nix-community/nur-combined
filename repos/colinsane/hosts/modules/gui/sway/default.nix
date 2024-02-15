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
    # the order of these `paths` is such that the desktop-file should claim share/wayland-sessions/sway.deskop,
    # overriding whatever the configuredSway provides
    paths = [ desktop-file configuredSway ];
    passthru = {
      inherit (configuredSway.passthru) providedSessions;
      # nixos/modules/programs/wayland/sway.nix will call `.override` on the package we provide it
      override = wrapSway sway';
    };
  };
  swayPackage = wrapSway pkgs.sway {
    extraOptions = [
      # "--debug"
    ];
    extraSessionCommands = ''
      # sway defaults to auto-generating a unix domain socket named "sway-ipc.$UID.NNNN.sock",
      # which allows for multiple sway sessions under the same user.
      # but the unpredictability makes static sandboxing & such difficult, so hardcode it:
      export SWAYSOCK="$XDG_RUNTIME_DIR/sway-ipc.sock"
    '';
    # withBaseWrapper sets XDG_CURRENT_DESKTOP=sway
    # and makes sure that sway is launched dbus-run-session.
    withBaseWrapper = true;
    # "wrapGAppsHook wrapper to execute sway with required environment variables for GTK applications."
    # this literally just sets XDG_DATA_DIRS to the gtk3 gsettings-schemas before launching sway.
    # notably, this pulls in the *build* gtk3 -- probably not in an incompatible way
    # but still as a mistake, and wasteful for cross compilation
    withGtkWrapper  = false;
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
    sane.gui.sway.useGreeter = mkOption {
      description = ''
        launch sway via a greeter (like greetd's gtkgreet).
        sway is usable without a greeter, but skipping the greeter means no PAM session.
        alternatively, one may launch it directly from a TTY, which does get a PAM session.
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

      screenshot_cmd = mkOption {
        type = types.str;
        default = "grimshot copy area";
        description = "command to run when user wants to take a screenshot";
      };
    };
  };

  config = lib.mkMerge [
    {
      sane.programs.sway = {
        packageUnwrapped = swayPackage;
        suggestedPrograms = [
          "guiApps"
          "blueberry"  # GUI bluetooth manager
          "brightnessctl"
          "conky"  # for a nice background
          "fuzzel"
          # "gnome.gnome-bluetooth"  # XXX(2023/05/14): broken
          # "gnome.gnome-control-center"  # XXX(2023/06/28): depends on webkitgtk4_1
          "playerctl"  # for waybar & particularly to have playerctld running
          "pulsemixer"  # for volume controls
          "splatmoji"  # used by sway config
          "sway-contrib.grimshot"  # used by sway config
          # "swayidle"  # enable if you need it
          "swaylock"  # used by sway config
          "swaynotificationcenter"  # notification daemon
          "waybar"  # used by sway config
          "wdisplays"  # like xrandr
          "wl-clipboard"
          "wob"  # render volume changes on-screen
          "xdg-desktop-portal"
          # xdg-desktop-portal-gtk provides portals for:
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
          # - org.freedesktop.impl.portal.Lockdown (@lockdown_iface@)
          # - org.freedesktop.impl.portal.Settings (@settings_iface@)
          # - org.freedesktop.impl.portal.Wallpaper (@wallpaper_iface@)
          "xdg-desktop-portal-gtk"
          # xdg-desktop-portal-wlr provides portals for screenshots/screen sharing
          "xdg-desktop-portal-wlr"
          "xdg-terminal-exec"  # used by sway config
        ];

        secrets.".config/sane-sway/snippets.txt" = ../../../../secrets/common/snippets.txt.bin;

        fs.".config/xdg-desktop-portal/sway-portals.conf".symlink.text = ''
          # portals.conf docs: <https://flatpak.github.io/xdg-desktop-portal/docs/portals.conf.html>
          [preferred]
          default=wlr;gtk
        '';

        fs.".config/sway/config".symlink.target = pkgs.callPackage ./sway-config.nix {
          inherit config;
          swayCfg = cfg.config;
        };

        services.sway-session = {
          description = "no-op unit to signal that sway is operational";
          documentation = [
            "https://github.com/swaywm/sway/issues/7862"
            "https://github.com/alebastr/sway-systemd"
          ];
          bindsTo = [ "graphical-session.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.coreutils}/bin/true";
            Type = "oneshot";
            RemainAfterExit = true;
          };
        };

      };
    }

    (lib.mkIf cfg.enable {
      sane.programs.fontconfig.enableFor.system = true;
      sane.programs.sway.enableFor.user.colin = true;

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

      sane.gui.unl0kr = lib.mkIf cfg.useGreeter {
        enable = true;
        afterLogin = "sway";
        user = "colin";
      };

      # swap in these lines to use `greetd`+`gtkgreet` instead:
      # sane.gui.greetd = lib.mkIf cfg.useGreeter {
      #   enable = true;
      #   sway.enable = true;  # have greetd launch a sway compositor in which we host a greeter
      #   sway.gtkgreet = {
      #     enable = true;
      #     session.name = "sway-on-gtkgreet";
      #     session.command = "${cfg.package}/bin/sway";  #< works, simplest way to run sway
      #     # session.command = "${pkgs.libcap}/bin/capsh --print";  # DEBUGGING

      #     # instead, want to run sway as a systemd user service.
      #     # this seems silly, but it allows the launched sway to access any linux capabilities which the systemd --user manager is granted.
      #     # notably, that means CAP_NET_ADMIN, CAP_NET_RAW; necessary for wireshark.
      #     # these capabilities are granted to systemd --user by pam. see the user definition in hosts/common/users/colin.nix for more.
      #     # session.command = "${pkgs.systemd}/bin/systemd-run --user --wait --collect --service-type=exec ${cfg.package}/bin/sway";  #< works, but can't launch terminals, etc ("exec: no such file" (sh))
      #     # session.command = ''${pkgs.systemd}/bin/systemd-run --user --wait --collect --service-type=exec -E "PATH=$PATH" -p AmbientCapabilities="cap_net_admin cap_net_raw" ${cfg.package}/bin/sway'';
      #   };
      # };

      # swap in these lines to use SDDM instead:
      # services.xserver.displayManager.sddm.enable = true;
      # services.xserver.enable = true;

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
      services.gvfs.package = lib.mkDefault (pkgs.gvfs.override {
        # i don't need to mount samba shares, and samba build is expensive/flaky (mostly for cross, but even problematic on native)
        samba = null;
      });
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

      programs.xwayland.enable = cfg.config.xwayland;

      # disable nixos' portal module, otherwise /share/applications gets linked into the system and complicates things (sandboxing).
      # instead, i manage portals myself via the sane.programs API (e.g. sane.programs.xdg-desktop-portal).
      xdg.portal.enable = false;
      xdg.menus.enable = false;  #< links /share/applications, and a bunch of other empty (i.e. unused) dirs

    })
  ];
}

