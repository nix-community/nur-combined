# this work derives from noneucat's sxmo service/packages, found via NUR
# - <repo:nix-community/nur-combined:repos/noneucat/modules/pinephone/sxmo.nix>
# other nix works:
# - <https://github.com/wentam/sxmo-nix>
#   - implements sxmo atop tinydm (also packaged by wentam)
#   - wentam cleans up sxmo-utils to be sealed. also patches to use systemd poweroff, etc
#   - packages a handful of anjan and proycon utilities
#   - packages <https://gitlab.com/kop316/mmsd/>
#   - packages <https://gitlab.com/kop316/vvmd/>
# - <https://github.com/chuangzhu/nixpkgs-sxmo>
#   - implements sxmo as a direct systemd service -- apparently no DM
#   - packages sxmo-utils
#     - injects PATH into each script
# - perhaps sxmo-utils is best packaged via the `resholve` shell solver?
#
# sxmo documentation:
# - <repo:anjan/sxmo-docs-next>
#
# sxmo technical overview:
# - inputs
#   - dwm: handles vol/power buttons; hardcoded in config.h
#   - lisgd: handles gestures
# - startup
#   - daemon based (lisgsd, idle_locker, statusbar_periodics)
#   - auto-started at login
#   - managable by `sxmo_daemons.sh`
#     - list available daemons: `sxmo_daemons.sh list`
#     - query if a daemon is active: `sxmo_daemons.sh running <my-daemon>`
#     - start daemon: `sxmo_daemons.sh start <my-daemon>`
#   - managable by `superctl`
#     - `superctl status`
# - user hooks:
#   - live in ~/.config/sxmo/hooks/
# - logs:
#   - live in ~/.local/state/sxmo.log
#   - ~/.local/state/superd.log
#   - ~/.local/state/superd/logs/<daemon>.log
#   - `journalctl --user --boot`  (lightm redirects the sxmo session stdout => systemd)
#
# - default components:
#   - DE:                  sway (if wayland), dwm (if X)
#   - menus:               bemenu (if wayland), dmenu (if X)
#   - gestures:            lisgd
#   - on-screen keyboard:  wvkbd (if wayland), svkbd (if X)
#
{ lib, config, pkgs, sane-lib, ... }:

let
  cfg = config.sane.gui.sxmo;
in
{
  options = with lib; {
    sane.gui.sxmo.enable = mkOption {
      default = false;
      type = types.bool;
    };
    sane.gui.sxmo.greeter = mkOption {
      type = types.enum [ "lightdm-mobile" "sway" ];
      default = "lightdm-mobile";
      description = ''
        which greeter to use.
        "lightdm-mobile" => keypad style greeter. can only enter digits 0-9 as password.
        "sway" => layered sway greeter. behaves as if you booted to swaylock.
      '';
    };
    sane.gui.sxmo.package = mkOption {
      type = types.package;
      default = pkgs.sxmo-utils;
      description = ''
        sxmo base scripts and hooks collection.
        consider overriding the outputs under /share/sxmo/default_hooks
        to insert your own user scripts.
      '';
    };
    sane.gui.sxmo.terminal = mkOption {
      # type = types.nullOr (types.enum [ "foot" "st" "vte" ]);
      type = types.nullOr types.str;
      default = "foot";
      description = ''
        name of terminal to use for sxmo_terminal.sh.
        foot, st, and vte have special integrations in sxmo, but any will work.
      '';
    };
    sane.gui.sxmo.keyboard = mkOption {
      # type = types.nullOr (types.enum ["wvkbd"])
      type = types.nullOr types.str;
      default = "wvkbd";
      description = ''
        name of on-screen-keyboard to use for sxmo_keyboard.sh.
        this sets the KEYBOARD environment variable.
        see also: KEYBOARD_ARGS.
      '';
    };
    sane.gui.sxmo.settings = mkOption {
      description = ''
        environment variables used to configure sxmo.
        e.g. SXMO_UNLOCK_IDLE_TIME or SXMO_VOLUME_BUTTON.
      '';
      type = types.submodule {
        freeformType = types.attrsOf types.str;
        options =
          let
            mkSettingsOpt = default: description: mkOption {
              inherit default description;
              type = types.nullOr types.str;
            };
          in {
            SXMO_BAR_SHOW_BAT_PER = mkSettingsOpt "1" "show battery percentage in statusbar";
            SXMO_UNLOCK_IDLE_TIME = mkSettingsOpt "300" "how many seconds of inactivity before locking the screen";  # lock -> screenoff happens 8s later, not configurable
          };
      };
      default = {};
    };
    sane.gui.sxmo.noidle = mkOption {
      type = types.bool;
      default = false;
      description = "inhibit lock-on-idle and screenoff-on-idle";
    };
  };

  config = lib.mkMerge [
    {
      sane.programs.sxmoApps = {
        package = null;
        suggestedPrograms = [
          "guiApps"
          "sfeed"  # want this here so that the user's ~/.sfeed/sfeedrc gets created
        ];
      };
    }

    {
      # TODO: lift to option declaration
      sane.gui.sxmo.settings.TERMCMD = lib.mkIf (cfg.terminal != null)
        (lib.mkDefault (if cfg.terminal == "vte" then "vte-2.91" else cfg.terminal));
      sane.gui.sxmo.settings.KEYBOARD = lib.mkIf (cfg.keyboard != null)
        (lib.mkDefault (if cfg.keyboard == "wvkbd" then "wvkbd-mobintl" else cfg.keyboard));
    }

    (lib.mkIf cfg.enable {
      sane.programs.sxmoApps.enableFor.user.colin = true;
      sane.gui.gtk.enable = lib.mkDefault true;

      # some programs (e.g. fractal/nheko) **require** a "Secret Service Provider"
      services.gnome.gnome-keyring.enable = true;

      networking.useDHCP = false;
      networking.networkmanager.enable = true;
      networking.wireless.enable = lib.mkForce false;

      hardware.bluetooth.enable = true;
      services.blueman.enable = true;

      # sxmo internally uses doas instead of sudo
      security.doas.enable = true;
      security.doas.wheelNeedsPassword = false;

      # TODO: nerdfonts is 4GB. it accepts an option to ship only some fonts: probably want to use that.
      fonts.fonts = [ pkgs.nerdfonts ];

      # sxmo has first-class support only for pulseaudio and alsa -- not pipewire.
      # however, pipewire can emulate pulseaudio support via `services.pipewire.pulse.enable = true`
      #   after which the stock pulseaudio binaries magically work
      # administer with pw-cli, pw-mon, pw-top commands
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;  # ??
        pulse.enable = true;
      };
      systemd.user.services."pipewire".wantedBy = [ "graphical-session.target" ];

      # TODO: could use `displayManager.sessionPackages`?
      environment.systemPackages = [
        cfg.package
      ] ++ lib.optionals (cfg.terminal != null) [ pkgs."${cfg.terminal}" ]
        ++ lib.optionals (cfg.keyboard != null) [ pkgs."${cfg.keyboard}" ];

      environment.sessionVariables = {
        XDG_DATA_DIRS = [
          # TODO: only need the share/sxmo directly linked
          "${cfg.package}/share"
        ];
      } // cfg.settings;

      sane.user.fs.".cache/sxmo/sxmo.noidle" = lib.mkIf cfg.noidle (sane-lib.fs.wantedText "");


      ## greeter

      services.xserver = lib.mkIf (cfg.greeter == "lightdm-mobile") {
        enable = true;

        displayManager.lightdm.enable = true;
        displayManager.lightdm.greeters.mobile.enable = true;
        displayManager.lightdm.extraSeatDefaults = ''
          user-session = swmo
        '';

        displayManager.sessionPackages = with pkgs; [
          cfg.package  # this gets share/wayland-sessions/swmo.desktop linked
        ];

        # taken from gui/phosh:
        # NB: setting defaultSession has the critical side-effect that it lets org.freedesktop.AccountsService
        # know that our user exists. this ensures lightdm succeeds when calling /org/freedesktop/AccountsServices ListCachedUsers
        # lightdm greeters get the login users from lightdm which gets it from org.freedesktop.Accounts.ListCachedUsers.
        # this requires the user we want to login as to be cached.
        displayManager.job.preStart = ''
          ${pkgs.systemd}/bin/busctl call org.freedesktop.Accounts /org/freedesktop/Accounts org.freedesktop.Accounts CacheUser s colin
        '';
      };

      services.greetd = lib.mkIf (cfg.greeter == "sway") {
        enable = true;
        # borrowed from gui/sway
        settings.default_session.command =
        let
          # start sway and have it construct the gtkgreeter
          sway-as-greeter = pkgs.writeShellScriptBin "sway-as-greeter" ''
            ${pkgs.sway}/bin/sway --debug --config ${sway-config-into-gtkgreet} > /var/log/sway/sway-as-greeter.log 2>&1
          '';
          # (config file for the above)
          sway-config-into-gtkgreet = pkgs.writeText "greetd-sway-config" ''
            exec "${gtkgreet-launcher}"
          '';
          # gtkgreet which launches a layered sway instance
          gtkgreet-launcher = pkgs.writeShellScript "gtkgreet-launcher" ''
            # NB: the "command" field here is run in the user's shell.
            # so that command must exist on the specific user's path who is logging in. it doesn't need to exist system-wide.
            ${pkgs.greetd.gtkgreet}/bin/gtkgreet --layer-shell --command sxmo_winit.sh
          '';
        in "${sway-as-greeter}/bin/sway-as-greeter";
      };

      systemd.services."sxmo-set-permissions" = {
        description = "configure specific /sys and /dev nodes to be writable by sxmo scripts";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${cfg.package}/bin/sxmo_setpermissions.sh";
        };
        wantedBy = [ "display-manager.service" ];
      };

      sane.fs."/var/log/sway" = lib.mkIf (cfg.greeter == "sway") {
        dir.acl.mode = "0777";
        wantedBeforeBy = [ "greetd.service" "display-manager.service" ];
      };

      # lightdm-mobile-greeter: "The name org.a11y.Bus was not provided by any .service files"
      services.gnome.at-spi2-core.enable = true;

      # services.xserver.windowManager.session = [{
      #   name = "sxmo";
      #   desktopNames = [ "sxmo" ];
      #   start = ''
      #     ${cfg.package}/bin/sxmo_xinit.sh &
      #     waitPID=$!
      #   '';
      # }];
      # services.xserver.enable = true;

      # services.greetd = {
      #   enable = true;
      #   settings = {
      #     default_session = {
      #       command = "${cfg.package}/bin/sxmo_winit.sh";
      #       user = "colin";
      #     };
      #   };
      # };
    })
  ];
}
