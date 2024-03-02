{ config, lib, pkgs, ... }:

# docs: https://nixos.wiki/wiki/Sway
# sway-config docs: `man 5 sway`
let
  cfg = config.sane.programs.sway;
  wrapSway = configuredSway: let
    # `wrapSway` exists to launch sway with our desired debugging facilities.
    # i.e. redirect output to syslog.
    systemd-cat = "${lib.getBin pkgs.systemd}/bin/systemd-cat";
    swayLauncher = pkgs.writeShellScriptBin "sway" ''
      # sway defaults to auto-generating a unix domain socket named "sway-ipc.$UID.NNNN.sock",
      # which allows for multiple sway sessions under the same user.
      # but the unpredictability makes static sandboxing & such difficult, so hardcode it:
      export SWAYSOCK="$XDG_RUNTIME_DIR/sway-ipc.sock"
      export XDG_CURRENT_DESKTOP=sway

      echo "launching sway (sway.desktop)..." | ${systemd-cat} --identifier=sway
      exec ${configuredSway}/bin/sway 2>&1 | ${systemd-cat} --identifier=sway
    '';
  in
    pkgs.symlinkJoin {
      inherit (configuredSway) meta version;
      name = "sway-wrapped";
      paths = [
        swayLauncher
        configuredSway
      ];
      passthru.sway-unwrapped = configuredSway;
    };
  swayPackage = wrapSway (
    pkgs.sway-unwrapped.override {
      # wlroots seems to launch Xwayland itself, and i can't easily just do that myself externally.
      # so in order for the Xwayland it launches to be sandboxed, i need to patch the sandboxed version in here.
      wlroots = pkgs.wlroots.override {
        xwayland = config.sane.programs.xwayland.package;
      };

      # about xwayland:
      # - required by many electron apps, though some electron apps support NIXOS_OZONE_WL=1 for native wayland.
      # - when xwayland is enabled, KOreader incorrectly chooses the X11 backend
      #   -> slower; blurrier
      # - xwayland uses a small amount of memory (like 30MiB, IIRC?)
      enableXWayland = config.sane.programs.xwayland.enabled;
    }
  );
in
{
  sane.programs.sway = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options = {
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
        };
      };
    };

    packageUnwrapped = swayPackage;
    suggestedPrograms = [
      "guiApps"
      "blueberry"  # GUI bluetooth manager
      "brightnessctl"
      "conky"  # for a nice background
      "fontconfig"
      # "gnome.gnome-bluetooth"  # XXX(2023/05/14): broken
      # "gnome.gnome-control-center"  # XXX(2023/06/28): depends on webkitgtk4_1
      "pipewire"
      "playerctl"  # for waybar & particularly to have playerctld running
      "pulsemixer"  # for volume controls
      "rofi"  # menu/launcher
      "rofi-snippets"
      "sane-screenshot"
      "sane-open-desktop"
      "splatmoji"  # used by sway config
      "sway-contrib.grimshot"  # used by sway config
      # "swayidle"  # enable if you need it
      "swaylock"  # used by sway config
      "swaynotificationcenter"  # notification daemon
      "unl0kr"  # greeter
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

    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";
    sandbox.whitelistAudio = true;  # it runs playerctl directly
    sandbox.whitelistDbus = [ "system" "user" ];  # to e.g. launch apps
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    # needs to *create* the sway socket. could move the sway socket into its own directory, and whitelist just that, but doesn't buy me much.
    sandbox.extraRuntimePaths = [ "/" ];
    sandbox.extraPaths = [
      "/dev/input"
      "/run/systemd"
      "/run/udev"
      "/sys/class/backlight"
      "/sys/class/drm"
      "/sys/class/input"
      "/sys/dev/char"
      "/sys/devices"
    ];
    sandbox.extraConfig = [
      "--sane-sandbox-keep-namespace" "pid"
    ];


    fs.".config/xdg-desktop-portal/sway-portals.conf".symlink.text = ''
      # portals.conf docs: <https://flatpak.github.io/xdg-desktop-portal/docs/portals.conf.html>
      [preferred]
      default=wlr;gtk
    '';

    fs.".config/sway/config".symlink.target = pkgs.substituteAll {
      src = ./sway-config;
      inherit (cfg.config)
        background
        extra_lines
        font
        mod
        workspace_layout
      ;
      xwayland = if config.sane.programs.xwayland.enabled then "enable" else "disable";
    };

    services.sway-session = {
      description = "sway-session: active iff sway desktop environment is baseline operational";
      documentation = [
        "https://github.com/swaywm/sway/issues/7862"
        "https://github.com/alebastr/sway-systemd"
      ];

      # we'd like to start graphical-session after sway is ready, but it's marked `RefuseManualStart` because Lennart.
      # instead, create `sway-session.service` which `bindsTo` `graphical-session.target`.
      # we can manually start `sway-session`, and the `bindsTo` means that it will start `graphical-session`,
      # and then track `graphical-session`s state (that is: it'll stop when graphical-session stops).
      #
      # additionally, set `ConditionEnvironment` to guard that the sway environment variables *really have* been imported into systemd.
      unitConfig.ConditionEnvironment = "SWAYSOCK";
      # requiredBy = [ "graphical-session.target" ];
      before = [ "graphical-session.target" ];
      bindsTo = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.coreutils}/bin/true";
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };


  sane.gui.gtk = lib.mkIf cfg.enabled {
    enable = lib.mkDefault true;
    # gtk-theme = lib.mkDefault "Fluent-Light-compact";
    gtk-theme = lib.mkDefault "Tokyonight-Light-B";
    # icon-theme = lib.mkDefault "HighContrast";  # 4/5 coverage on moby
    # icon-theme = lib.mkDefault "WhiteSur";  # 3.5/5 coverage on moby, but it provides a bunch for Fractal/Dino
    # icon-theme = lib.mkDefault "Humanity";  # 3.5/5 coverage on moby, but it provides the bookmark icon
    # icon-theme = lib.mkDefault "Paper";  # 3.5/5 coverage on moby, but it provides the bookmark icon
    # icon-theme = lib.mkDefault "Nordzy";  # 3/5 coverage on moby
    # icon-theme = lib.mkDefault "Fluent";  # 3/5 coverage on moby
    # icon-theme = lib.mkDefault "Colloid";  # 3/5 coverage on moby
    # icon-theme = lib.mkDefault "Qogir";  # 2.5/5 coverage on moby
    # icon-theme = lib.mkDefault "rose-pine-dawn";  # 2.5/5 coverage on moby
    # icon-theme = lib.mkDefault "Flat-Remix-Grey-Light";  # requires qtbase
  };

  services.gvfs = lib.mkIf cfg.enabled {
    enable = true;  # allow nautilus to mount remote filesystems (e.g. ftp://...)
    package = lib.mkDefault (pkgs.gvfs.override {
      # i don't need to mount samba shares, and samba build is expensive/flaky (mostly for cross, but even problematic on native)
      samba = null;
    });
  };


  # TODO: this can go elsewhere
  networking.networkmanager.enable = lib.mkIf cfg.enabled true;
  hardware.bluetooth.enable = lib.mkIf cfg.enabled true;
  services.blueman.enable = lib.mkIf cfg.enabled true;

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
}

