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
# sxmo upstream links:
# - docs (rendered): <https://man.sr.ht/~anjan/sxmo-docs-next/>
# - issue tracker: <https://todo.sr.ht/~mil/sxmo-tickets>
# - mail list (patches): <https://lists.sr.ht/~mil/sxmo-devel>
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
#   - `journalctl --user --boot`  (lightdm redirects the sxmo session stdout => systemd)
#
# - default components:
#   - DE:                  sway (if wayland), dwm (if X)
#   - menus:               bemenu (if wayland), dmenu (if X)
#   - gestures:            lisgd
#   - on-screen keyboard:  wvkbd (if wayland), svkbd (if X)
#
# TODO:
# - theme `mako` notifications
{ config, lib, pkgs, ... }:

let
  cfg = config.sane.gui.sxmo;
  package = cfg.package;
  knownKeyboards = {
    # map keyboard package name -> name of binary to invoke
    wvkbd = "wvkbd-mobintl";
    svkbd = "svkbd-mobile-intl";
  };
  knownTerminals = {
    vte = "vte-2.91";
  };

  systemd-cat = "${pkgs.systemd}/bin/systemd-cat";
  runWithLogger = identifier: cmd: pkgs.writeShellScript identifier ''
    echo "launching ${identifier}..." | ${systemd-cat} --identifier=${identifier}
    ${cmd} 2>&1 | ${systemd-cat} --identifier=${identifier}
  '';

  hookPkgs = {
    inputhandler = pkgs.static-nix-shell.mkBash {
      pname = "sxmo_hook_inputhandler.sh";
      src = ./hooks;
      pkgs = [ "coreutils" ];
    };
    start = pkgs.static-nix-shell.mkBash {
      pname = "sxmo_hook_start.sh";
      src = ./hooks;
      pkgs = [ "superd" "xdg-user-dirs" ];
    };
    postwake = pkgs.static-nix-shell.mkBash {
      pname = "sxmo_hook_postwake.sh";
      src = ./hooks;
    };
  };
in
{
  options = with lib; {
    sane.gui.sxmo.enable = mkOption {
      default = false;
      type = types.bool;
    };
    sane.gui.sxmo.greeter = mkOption {
      type = types.enum [
        "greetd-phog"
        "greetd-sway-gtkgreet"
        "greetd-sway-phog"
        "greetd-sxmo"
        "lightdm-mobile"
      ];
      # default = "lightdm-mobile";
      default = "greetd-sway-phog";
      description = ''
        which greeter to use.
        "greetd-phog"          => phosh-based greeter. keypad (0-9) with option to open an on-screen keyboard.
        "greetd-sway-phog"     => phog, but uses sway as the compositor instead of phoc.
                              requires a patched phog, since sway doesn't provide the Wayland global "zphoc_layer_shell_effects_v1".
        "greetd-sxmo"          => launch sxmo directly from greetd, no auth.
                                  this means no keychain unlocked or encrypted home mounted.
        "lightdm-mobile"       => keypad style greeter. can only enter digits 0-9 as password.
        "greetd-sway-gtkgreet" => layered sway greeter. keyboard-only user/pass input; impractical on mobile.
      '';
    };
    sane.gui.sxmo.package = mkOption {
      type = types.package;
      default = pkgs.sxmo-utils-latest;
      description = ''
        sxmo base scripts and hooks collection.
        consider overriding the outputs under /share/sxmo/default_hooks
        to insert your own user scripts.
      '';
    };
    sane.gui.sxmo.hooks = mkOption {
      type = types.attrsOf types.path;
      default = {
        "sxmo_hook_start.sh" = "${hookPkgs.start}/bin/sxmo_hook_start.sh";
        "sxmo_hook_inputhandler.sh" = "${hookPkgs.inputhandler}/bin/sxmo_hook_inputhandler.sh";
        "sxmo_hook_postwake.sh" = "${hookPkgs.postwake}/bin/sxmo_hook_postwake.sh";
      };
      description = ''
        extra hooks to add with higher priority than the builtins
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
            SXMO_DISABLE_CONFIGVERSION_CHECK = mkSettingsOpt "1" "allow omitting the configversion line from user-provided sxmo dotfiles";
            SXMO_UNLOCK_IDLE_TIME = mkSettingsOpt "300" "how many seconds of inactivity before locking the screen";  # lock -> screenoff happens 8s later, not configurable
            # SXMO_WM = mkSettingsOpt "sway" "sway or dwm. ordinarily initialized by sxmo_{x,w}init.sh";
          };
      };
      default = {};
    };
    sane.gui.sxmo.noidle = mkOption {
      type = types.bool;
      default = false;
      description = "inhibit lock-on-idle and screenoff-on-idle";
    };
    sane.gui.sxmo.nogesture = mkOption {
      type = types.bool;
      default = false;
      description = "don't start lisgd gesture daemon by default";
    };
  };

  config = lib.mkMerge [
    {
      sane.programs.sxmoApps = {
        package = null;
        suggestedPrograms = [
          "guiApps"
          "sfeed"      # want this here so that the user's ~/.sfeed/sfeedrc gets created
          "superd"     # make superctl (used by sxmo) be on PATH
        ];

        persist.cryptClearOnBoot = [
          # builds to be 10's of MB per day
          ".local/state/superd/logs"
        ];
      };
    }

    {
      # TODO: lift to option declaration
      # N.B.: TERMCMD was renamed SXMO_TERMINAL on 2023/08/29
      sane.gui.sxmo.settings.SXMO_TERMINAL = lib.mkIf (cfg.terminal != null)
        (lib.mkDefault (knownTerminals."${cfg.terminal}" or cfg.terminal));
      sane.gui.sxmo.settings.KEYBOARD = lib.mkIf (cfg.keyboard != null)
        (lib.mkDefault (knownKeyboards."${cfg.keyboard}" or cfg.keyboard));
    }

    (lib.mkIf cfg.enable (lib.mkMerge [
      {
        sane.gui.sway = {
          enable = true;
          # we manage the greeter ourselves  (TODO: merge this into sway config as well)
          useGreeter = false;
          waybar.top = import ./waybar-top.nix;
          # reset extra waybar style
          waybar.extra_style = "";
          config = {
            # N.B. missing from upstream sxmo config here is:
            # - `bindsym $mod+g exec sxmo_hook_locker.sh`
            # - `bindsym $mod+t exec sxmo_appmenu.sh power`
            # - `bindsym $mod+i exec sxmo_wmmenu.sh windowswitcher`
            # - `bindsym $mod+p exec sxmo_appmenu.sh`
            # - `bindsym $mod+Shift+p exec sxmo_appmenu.sh sys`
            # - `input * xkb_options compose:ralt`
            # these could be added, but i don't see much benefit.
            font = "pango:monospace 10";
            mod = "Mod1";  # prefer Alt
            xwayland = false;  # disable to reduce RAM usage.
            workspace_layout = "tabbed";

            brightness_down_cmd = "sxmo_brightness.sh down";
            brightness_up_cmd = "sxmo_brightness.sh up";
            screenshot_cmd = "sxmo_screenshot.sh";
            extra_lines =
              let
                sxmo_init = pkgs.writeShellScript "sxmo_init.sh" ''
                  # perform the same behavior as sxmo_{x,w}init.sh -- but without actually launching wayland/X11
                  # this amounts to:
                  # - setting env vars (e.g. getting the hooks onto PATH)
                  # - placing default configs in ~ for sxmo-launched services (sxmo_migrate.sh)
                  # - binding vol/power buttons (sxmo_swayinitconf.sh)
                  # - launching sxmo_hook_start.sh
                  #
                  # the commands here are similar to upstream sxmo_winit.sh, but not identical and the ordering may be different

                  # profile may contain SXMO_DEVICE_NAME which is used by _sxmo_load_environment so load it early
                  source "$XDG_CONFIG_HOME/sxmo/profile"
                  # sourcing upstream sxmo_init.sh triggers _sxmo_load_environment
                  # which ensures SXMO_* environment variables are set
                  source ${package}/etc/profile.d/sxmo_init.sh
                  # _sxmo_prepare_dirs ensures ~/.cache/sxmo & other XDG dirs exist with correct perms & owner
                  _sxmo_prepare_dirs
                  # migrate tells sxmo to provide the following default files:
                  # - ~/.config/sxmo/profile
                  # - ~/.config/fontconfig/conf.d/50-sxmo.conf
                  # - ~/.config/sxmo/sway
                  # - ~/.config/foot/foot.ini
                  # - ~/.config/mako/config
                  # - ~/.config/sxmo/bonsai_tree.json
                  # - ~/.config/wob/wob.ini
                  # - ~/.config/sxmo/conky.conf
                  sxmo_migrate.sh sync
                  # various things may have happened above that require me to re-load the profile here:
                  # - _sxmo_load_environment sources a deviceprofile.sh file, which may override my profile settings.
                  #   very obvious if you set a non-default SXMO_SWAY_SCALE.
                  # - sxmo_migrate.sh may have provided a default profile, if i failed to
                  source "$XDG_CONFIG_HOME/sxmo/profile"
                  # place my non-specialized hooks at higher precedence than the default device-hooks
                  # alternative would be to move my hooks to ~/.config/sxmo/hooks/<device-name>.
                  export PATH="$XDG_CONFIG_HOME/sxmo/hooks:$PATH"

                  # kill anything leftover from the previous sxmo run. this way we can (try to) be reentrant
                  echo "sxmo_init: killing stale daemons (if active)"
                  sxmo_daemons.sh stop all
                  pkill bemenu
                  pkill wvkbd
                  pkill superd

                  # configure vol/power-button input mapping (upstream SXMO has this in sway config)
                  echo "sxmo_init: configuring sway bindings/displays with:"
                  echo "SXMO_POWER_BUTTON: $SXMO_POWER_BUTTON"
                  echo "SXMO_VOLUME_BUTTON: $SXMO_VOLUME_BUTTON"
                  echo "SXMO_SWAY_SCALE: $SXMO_SWAY_SCALE"
                  sxmo_swayinitconf.sh

                  echo "sxmo_init: invoking sxmo_hook_start.sh with:"
                  echo "PATH: $PATH"
                  sxmo_hook_start.sh
                '';
              in ''
                # TODO: some of this is probably unnecessary
                mode "menu" {
                  # just a placeholder for "menu" mode
                  bindsym --input-device=1:1:1c21800.lradc XF86AudioMute exec nothing
                }
                bindsym button2 kill
                bindswitch lid:on exec sxmo_wm.sh dpms on
                bindswitch lid:off exec sxmo_wm.sh dpms off
                exec 'printf %s "$SWAYSOCK" > "$XDG_RUNTIME_DIR"/sxmo.swaysock'
                exec_always ${sxmo_init}
              '';
          };
        };

        sane.programs.sxmoApps.enableFor.user.colin = true;

        # sxmo internally uses doas instead of sudo
        security.doas.enable = true;
        security.doas.wheelNeedsPassword = false;

        # lightdm-mobile-greeter: "The name org.a11y.Bus was not provided by any .service files"
        services.gnome.at-spi2-core.enable = true;


        # TODO: could use `displayManager.sessionPackages`?
        environment.systemPackages = [
          package
          pkgs.bonsai  # sway (not sxmo) needs to exec `bonsaictl` by name (sxmo_swayinitconf.sh)
        ] ++ lib.optionals (cfg.terminal != null) [ pkgs."${cfg.terminal}" ]
          ++ lib.optionals (cfg.keyboard != null) [ pkgs."${cfg.keyboard}" ];

        environment.sessionVariables = {
          XDG_DATA_DIRS = [
            # TODO: only need the share/sxmo directly linked
            "${package}/share"
          ];
        } // (lib.filterAttrs  # certain settings are read before the `profile` is sourced
          (k: v: k == "SXMO_DISABLE_CONFIGVERSION_CHECK")
          cfg.settings
        );

        # sxmo puts in /share/sxmo:
        # - profile.d/sxmo_init.sh
        # - appcfg/
        # - default_hooks/
        # - and more
        # environment.pathsToLink = [ "/share/sxmo" ];

        systemd.services."sxmo-set-permissions" = {
          # TODO: some of these could be modified to be udev rules
          description = "configure specific /sys and /dev nodes to be writable by sxmo scripts";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${package}/bin/sxmo_setpermissions.sh";
          };
          wantedBy = [ "multi-user.target" ];
        };

        # if superd fails to start a service within 100ms, it'll try to start again
        # the fallout of this is that during intense lag (e.g. OOM or swapping) it can
        # start the service many times.
        # see <repo:craftyguy/superd:internal/cmd/cmd.go>
        # TODO: better fix may be to patch `sxmo_hook_lisgdstart.sh` and force it to behave as a singleton
        systemd.services."dedupe-sxmo-lisgd" = {
          description = "kill duplicate lisgd processes started by superd";
          serviceConfig = {
            Type = "oneshot";
          };
          script = ''
            if [ "$(${pkgs.procps}/bin/pgrep -c lisgd)" -gt 1 ]; then
              echo 'killing duplicated lisgd daemons'
              ${pkgs.psmisc}/bin/killall lisgd  # let superd restart it
            fi
          '';
          wantedBy = [ "multi-user.target" ];
        };
        systemd.timers."dedupe-sxmo-lisgd" = {
          wantedBy = [ "dedupe-sxmo-lisgd.service" ];
          timerConfig = {
            OnUnitActiveSec = "2min";
          };
        };

        sane.user.fs = lib.mkMerge [
          {
            ".cache/sxmo/sxmo.noidle" = lib.mkIf cfg.noidle {
              symlink.text = "";
            };
            ".cache/sxmo/sxmo.nogesture" = lib.mkIf cfg.nogesture {
              symlink.text = "";
            };
            ".config/sxmo/profile".symlink.text = let
              mkKeyValue = key: value: ''export ${key}="${value}"'';
            in
              lib.generators.toKeyValue { inherit mkKeyValue; } cfg.settings;
          }
          (lib.mapAttrs' (name: value: {
            # sxmo's `_sxmo_load_environments` adds to PATH:
            # - ~/.config/sxmo/hooks/$SXMO_DEVICE_NAME
            # - ~/.config/sxmo/hooks
            name = ".config/sxmo/hooks/${name}";
            value.symlink.target = value;
          }) cfg.hooks)
        ];
      }

      (lib.mkIf (cfg.greeter == "lightdm-mobile") {
        sane.persist.sys.plaintext = [
          # this takes up 4-5 MB of fontconfig and mesa shader caches.
          # it could optionally be cleared on boot.
          { path = "/var/lib/lightdm"; user = "lightdm"; group = "lightdm"; mode = "0770"; }
        ];

        services.xserver = {
          enable = true;

          displayManager.lightdm.enable = true;
          displayManager.lightdm.greeters.mobile.enable = true;
          displayManager.lightdm.extraSeatDefaults = ''
            user-session = swmo
          '';

          displayManager.sessionPackages = with pkgs; [
            package  # this gets share/wayland-sessions/swmo.desktop linked
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
      })

      (lib.mkIf (cfg.greeter == "greetd-sway-gtkgreet") {
        sane.gui.greetd = {
          enable = true;
          sway.enable = true;
          sway.gtkgreet.enable = true;
          sway.gtkgreet.session.name = "sxmo-on-gtkgreet";
          sway.gtkgreet.session.command = "${pkgs.sway}/bin/sway --debug";
        };
      })

      (lib.mkIf (cfg.greeter == "greetd-sway-phog") {
        sane.gui.greetd = {
          enable = true;
          sway.enable = true;
          sway.greeterCmd = "${pkgs.phog}/libexec/phog";
        };
        # phog locates sxmo_winit.sh (or sway.desktop) via <env>/share/wayland-sessions
        environment.pathsToLink = [ "/share/wayland-sessions" ];
      })

      (lib.mkIf (cfg.greeter == "greetd-phog") {
        sane.gui.greetd = {
          enable = true;
          session.name = "phog";
          session.command = "${pkgs.phog}/bin/phog";
        };
        # phog locates sxmo_winit.sh (or sway.desktop) via <env>/share/wayland-sessions
        environment.pathsToLink = [ "/share/wayland-sessions" ];
      })

      (lib.mkIf (cfg.greeter == "greetd-sxmo") {
        sane.gui.greetd = {
          enable = true;
          session.name = "sxmo";
          # session.command = "${package}/bin/sxmo_winit.sh";
          session.command = "${pkgs.sway}/bin/sway --debug";
          session.user = "colin";
        };
      })

      # old, greeterless options:
      # services.xserver.windowManager.session = [{
      #   name = "sxmo";
      #   desktopNames = [ "sxmo" ];
      #   start = ''
      #     ${package}/bin/sxmo_xinit.sh &
      #     waitPID=$!
      #   '';
      # }];
      # services.xserver.enable = true;
    ]))
  ];
}
