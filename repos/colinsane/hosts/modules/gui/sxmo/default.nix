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
# other OS works:
# - <https://git.sr.ht/~aren/sxmo-utils> (arch)
# - perhaps sxmo-utils is best packaged via the `resholve` shell solver?
#
# sxmo upstream links:
# - docs (rendered): <https://man.sr.ht/~anjan/sxmo-docs-next/>
# - issue tracker: <https://todo.sr.ht/~mil/sxmo-tickets>
# - mail list (patches): <https://lists.sr.ht/~mil/sxmo-devel>
#
# sxmo technical overview:
# - inputs
#   - bonsaid: handles vol/power buttons
#     - it receives those buttons from dwm (if x11) harcoded in config.h or sway (if wayland)
#   - lisgd: handles gestures
# - startup
#   - daemon based (lisgsd, idle_locker, statusbar_periodics)
#   - auto-started at login
#   - managable by `sxmo_jobs.sh`
#     - list available daemons: `sxmo_jobs.sh list`
#     - query if a daemon is active: `sxmo_jobs.sh running <my-daemon>`
#     - start daemon: `sxmo_jobs.sh start <my-daemon>`
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
    block_suspend = pkgs.static-nix-shell.mkBash {
      pname = "sxmo_hook_block_suspend.sh";
      pkgs = [ "procps" ];
      srcRoot = ./hooks;
    };
    inputhandler = pkgs.static-nix-shell.mkBash {
      pname = "sxmo_hook_inputhandler.sh";
      pkgs = [ "coreutils" "playerctl" "pulseaudio" ];
      srcRoot = ./hooks;
    };
    postwake = pkgs.static-nix-shell.mkBash {
      pname = "sxmo_hook_postwake.sh";
      pkgs = [ "coreutils" ];
      srcRoot = ./hooks;
    };
    rotate = pkgs.static-nix-shell.mkBash {
      pname = "sxmo_hook_rotate.sh";
      pkgs = {
        sway = config.sane.programs.sway.package.sway-unwrapped;
      };
      srcRoot = ./hooks;
    };
    start = pkgs.static-nix-shell.mkBash {
      pname = "sxmo_hook_start.sh";
      pkgs = [ "systemd" "xdg-user-dirs" ];
      srcRoot = ./hooks;
    };
    suspend = pkgs.static-nix-shell.mkPython3Bin {
      pname = "sxmo_suspend.sh";
      pkgs = [ "rtl8723cs-wowlan" "util-linux" ];
      srcRoot = ./hooks;
      extraMakeWrapperArgs = [ "--add-flags" "--verbose" ];
    };
  };
in
{
  options = with lib; {
    sane.gui.sxmo.enable = mkOption {
      default = false;
      type = types.bool;
    };
    sane.gui.sxmo.package = mkOption {
      type = types.package;
      default = pkgs.sxmo-utils.override {
        preferSystemd = true;
        sway = config.sane.programs.sway.package.sway-unwrapped;
      };
      description = ''
        sxmo base scripts and hooks collection.
        consider overriding the outputs under /share/sxmo/default_hooks
        to insert your own user scripts.
      '';
    };
    sane.gui.sxmo.hooks = mkOption {
      type = types.attrsOf types.path;
      default = {
        # default upstream hooks
        # additional hooks are in subdirectories like three_button_touchscreen/
        # - sxmo_hook_inputhandler.sh
        # - sxmo_hook_lock.sh
        # - sxmo_hook_postwake.sh
        # - sxmo_hook_screenoff.sh
        # - sxmo_hook_unlock.sh
        # by including hooks here, updating the sxmo package also updates the hooks
        # without requiring any reboot
        "sxmo_hook_apps.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_apps.sh";
        # "sxmo_hook_block_suspend.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_block_suspend.sh";
        "sxmo_hook_call_audio.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_call_audio.sh";
        "sxmo_hook_contextmenu_fallback.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_contextmenu_fallback.sh";
        "sxmo_hook_contextmenu.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_contextmenu.sh";
        "sxmo_hook_desktop_widget.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_desktop_widget.sh";
        "sxmo_hook_discard.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_discard.sh";
        "sxmo_hook_hangup.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_hangup.sh";
        "sxmo_hook_icons.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_icons.sh";
        "sxmo_hook_lisgdstart.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_lisgdstart.sh";
        "sxmo_hook_logout.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_logout.sh";
        "sxmo_hook_missed_call.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_missed_call.sh";
        "sxmo_hook_mnc.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_mnc.sh";
        "sxmo_hook_modem.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_modem.sh";
        "sxmo_hook_mute_ring.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_mute_ring.sh";
        "sxmo_hook_network_down.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_network_down.sh";
        "sxmo_hook_network_pre_down.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_network_pre_down.sh";
        "sxmo_hook_network_pre_up.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_network_pre_up.sh";
        "sxmo_hook_network_up.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_network_up.sh";
        "sxmo_hook_notification.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_notification.sh";
        "sxmo_hook_notifications.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_notifications.sh";
        "sxmo_hook_pickup.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_pickup.sh";
        "sxmo_hook_restart_modem_daemons.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_restart_modem_daemons.sh";
        "sxmo_hook_ring.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_ring.sh";
        "sxmo_hook_rotate.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_rotate.sh";
        "sxmo_hook_screenoff.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_screenoff.sh";
        "sxmo_hook_scripts.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_scripts.sh";
        "sxmo_hook_sendsms.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_sendsms.sh";
        "sxmo_hook_smslog.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_smslog.sh";
        "sxmo_hook_sms.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_sms.sh";
        "sxmo_hook_start.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_start.sh";
        "sxmo_hook_statusbar.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_statusbar.sh";
        "sxmo_hook_stop.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_stop.sh";
        "sxmo_hook_tailtextlog.sh" = "${package}/share/sxmo/default_hooks/sxmo_hook_tailtextlog.sh";
      } // {
        # default hooks for this nix module, not upstreamable
        "sxmo_hook_block_suspend.sh" = "${hookPkgs.block_suspend}/bin/sxmo_hook_block_suspend.sh";
        "sxmo_hook_inputhandler.sh" = "${hookPkgs.inputhandler}/bin/sxmo_hook_inputhandler.sh";
        "sxmo_hook_postwake.sh" = "${hookPkgs.postwake}/bin/sxmo_hook_postwake.sh";
        "sxmo_hook_rotate.sh" = "${hookPkgs.rotate}/bin/sxmo_hook_rotate.sh";
        "sxmo_hook_start.sh" = "${hookPkgs.start}/bin/sxmo_hook_start.sh";
        "sxmo_suspend.sh" = "${hookPkgs.suspend}/bin/sxmo_suspend.sh";
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
            SXMO_NO_AUDIO = mkSettingsOpt "" "don't start pipewire/pulseaudio in sxmo_hook_start.sh, don't show audio in statusbar, disable audio menu";
            SXMO_STATES = mkSettingsOpt "unlock screenoff" "list of states the device should support (unlock, lock, screenoff)";
            SXMO_SWAY_SCALE = mkSettingsOpt "1" "sway output scale";
            SXMO_WOB_DISABLE = mkSettingsOpt "" "disable the on-screen volume display";
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
        packageUnwrapped = null;
        suggestedPrograms = [
          "guiApps"
          "bemenu"  # specifically to import its theming
          "bonsai"
          "sfeed"   # want this here so that the user's ~/.sfeed/sfeedrc gets created
          # "superd"  # make superctl (used by sxmo) be on PATH
          # "sway-autoscaler"
          "waybar-sxmo-status"
        ];

        persist.byStore.cryptClearOnBoot = [
          # builds to be 10's of MB per day
          # ".local/state/superd/logs"
          ".local/share/sxmo/modem"  # SMS
          ".local/share/sxmo/notifications" # so i can see new SMS messages. not sure actually if this needs persisting or if it'll re-hydrate from modem.
        ];
      };

      sane.programs.waybar-sxmo-status = {
        packageUnwrapped = pkgs.static-nix-shell.mkBash {
          pname = "waybar-sxmo-status";
          srcRoot = ./.;
          pkgs = {
            sxmo-utils = package;
            "sxmo-utils.runtimeDeps" = package.runtimeDeps;
          };
        };
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
        sane.programs.sway.enableFor.user.colin = true;
        sane.programs.waybar.config = {
          top = import ./waybar-top.nix;
          fontSize = 14;
        };
        sane.programs.sway.config = {
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
          workspace_layout = "tabbed";

          # screenshot_cmd = "sxmo_screenshot.sh";
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
                sxmo_jobs.sh stop all
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

              # XXX(2023/12/04): this shouldn't be necessary, but without this Komikku fails to launch because XDG_SESSION_TYPE is unset

              exec dbus-update-activation-environment --systemd XDG_SESSION_TYPE
              exec_always ${sxmo_init}
            '';
        };

        sane.programs.sxmoApps.enableFor.user.colin = true;

        sane.programs.sway-autoscaler.config.defaultScale = builtins.fromJSON cfg.settings.SXMO_SWAY_SCALE;

        # sxmo internally uses doas instead of sudo
        security.doas.enable = true;
        security.doas.wheelNeedsPassword = false;

        # lightdm-mobile-greeter: "The name org.a11y.Bus was not provided by any .service files"
        services.gnome.at-spi2-core.enable = true;

        environment.systemPackages = [
          package
        ] ++ lib.optionals (cfg.terminal != null) [ pkgs."${cfg.terminal}" ]
          ++ lib.optionals (cfg.keyboard != null) [ pkgs."${cfg.keyboard}" ];

        environment.sessionVariables = {
          XDG_DATA_DIRS = [
            # TODO: only need the share/sxmo directly linked
            "${package}/share"
          ];
        } // (lib.filterAttrs (k: v:
            k == "SXMO_DISABLE_CONFIGVERSION_CHECK"  # read before `profile` is sourced
            || k == "SXMO_TERMINAL"  # for apps launched via `swaymsg exec -- sxmo_terminal.sh ...`
          )
          cfg.settings
        );


        sane.programs.bonsai.config.transitions = let
          doExec = inputName: transitions: {
            type = "exec";
            command = [
              "setsid"
              "-f"
              "sxmo_hook_inputhandler.sh"
              inputName
            ];
            inherit transitions;
          };
          onDelay = ms: transitions: {
            type = "delay";
            delay_duration = ms * 1000000;
            inherit transitions;
          };
          onEvent = eventName: transitions: {
            type = "event";
            event_name = eventName;
            inherit transitions;
          };
          friendlyToBonsai = { trigger ? null, terminal ? false, timeout ? {}, power_pressed ? {}, power_released ? {}, voldown_pressed ? {}, voldown_released ? {}, volup_pressed ? {}, volup_released ? {} }@args:
          if trigger != null then [
            (doExec trigger (friendlyToBonsai (builtins.removeAttrs args ["trigger"])))
          ] else let
            events = [ ]
              ++ (lib.optional (timeout != {})          (onDelay (timeout.ms or 400) (friendlyToBonsai (builtins.removeAttrs timeout ["ms"]))))
              ++ (lib.optional (power_pressed != {})    (onEvent "power_pressed" (friendlyToBonsai power_pressed)))
              ++ (lib.optional (power_released != {})   (onEvent "power_released" (friendlyToBonsai power_released)))
              ++ (lib.optional (voldown_pressed != {})  (onEvent "voldown_pressed" (friendlyToBonsai voldown_pressed)))
              ++ (lib.optional (voldown_released != {}) (onEvent "voldown_released" (friendlyToBonsai voldown_released)))
              ++ (lib.optional (volup_pressed != {})    (onEvent "volup_pressed" (friendlyToBonsai volup_pressed)))
              ++ (lib.optional (volup_released != {})   (onEvent "volup_released" (friendlyToBonsai volup_released)))
            ;
            in assert terminal -> events == []; events;

          # trigger ${button}_hold_N every `holdTime` ms until ${button} is released
          recurseHold = button: { count ? 1, maxHolds ? 5, prefix ? "", holdTime ? 600, ... }@opts: lib.optionalAttrs (count <= maxHolds) {
            "${button}_released".terminal = true;  # end the hold -> back to root state
            timeout = {
              ms = holdTime;
              trigger = "${prefix}${button}_hold_${builtins.toString count}";
            } // (recurseHold button (opts // { count = count+1; }));
          };

          # trigger volup_tap_N or voldown_tap_N on every tap.
          # if a volume button is held, then switch into `recurseHold`'s handling instead
          volumeActions = { count ? 1, maxTaps ? 5, prefix ? "", timeout ? 600, ... }@opts: lib.optionalAttrs (count != maxTaps) {
            volup_pressed = (recurseHold "volup" opts) // {
              volup_released = {
                trigger = "${prefix}volup_tap_${builtins.toString count}";
                timeout.ms = timeout;
              } // (volumeActions (opts // { count = count+1; }));
            };
            voldown_pressed = (recurseHold "voldown" opts) // {
              voldown_released = {
                trigger = "${prefix}voldown_tap_${builtins.toString count}";
                timeout.ms = timeout;
              } // (volumeActions (opts // { count = count+1; }));
            };
          };
        in friendlyToBonsai {
          # map sequences of "events" to an argument to pass to sxmo_hook_inputhandler.sh

          # map: power (short), power (short) x2, power (long)
          power_pressed.timeout.ms = 900; # press w/o release. this is a long timeout because it's tied to the "kill window" action.
          power_pressed.timeout.trigger = "powerhold";
          power_pressed.power_released.timeout.trigger = "powerbutton_one";
          power_pressed.power_released.timeout.ms = 300;
          power_pressed.power_released.power_pressed.trigger = "powerbutton_two";

          # map: volume taps and holds
          volup_pressed = (recurseHold "volup" {}) // {
            # this either becomes volup_hold_* (via recurseHold, above) or:
            # - a short volup_tap_1 followed by:
            #   - a *finalized* volup_1 (i.e. end of action)
            #   - more taps/holds, in which case we prefix it with `modal_<action>`
            #     to denote that we very explicitly entered this state.
            #
            # it's clunky: i do it this way so that voldown can map to keyboard/terminal in unlock mode
            #   but trigger media controls in screenoff
            #   in a way which *still* allows media controls if explicitly entered into via a tap on volup first
            volup_released = (volumeActions { prefix = "modal_"; }) // {
              trigger = "volup_tap_1";
              timeout.ms = 300;
              timeout.trigger = "volup_1";
            };
          };
          voldown_pressed = (volumeActions {}).voldown_pressed // {
            trigger = "voldown_start";
          };
        };

        # sxmo puts in /share/sxmo:
        # - profile.d/sxmo_init.sh
        # - appcfg/
        # - default_hooks/
        # - and more
        # environment.pathsToLink = [ "/share/sxmo" ];

        # if superd fails to start a service within 100ms, it'll try to start again
        # the fallout of this is that during intense lag (e.g. OOM or swapping) it can
        # start the service many times.
        # see <repo:craftyguy/superd:internal/cmd/cmd.go>
        #   startTimerDuration = 100 * time.Millisecond
        # TODO: better fix may be to patch `sxmo_hook_lisgdstart.sh` and force it to behave as a singleton
        # systemd.services."dedupe-sxmo-lisgd" = {
        #   description = "kill duplicate lisgd processes started by superd";
        #   serviceConfig = {
        #     Type = "oneshot";
        #   };
        #   script = ''
        #     if [ "$(${pkgs.procps}/bin/pgrep -c lisgd)" -gt 1 ]; then
        #       echo 'killing duplicated lisgd daemons'
        #       ${pkgs.psmisc}/bin/killall lisgd  # let superd restart it
        #     fi
        #   '';
        #   wantedBy = [ "multi-user.target" ];
        # };
        # systemd.timers."dedupe-sxmo-lisgd" = {
        #   wantedBy = [ "dedupe-sxmo-lisgd.service" ];
        #   timerConfig = {
        #     OnUnitActiveSec = "2min";
        #   };
        # };

        sane.user.fs = lib.mkMerge [
          {
            # link the superd services into a place where systemd can find them.
            # the unit files should be compatible, except maybe for PATH handling
            # ".config/systemd/user/autocutsel-primary.service".symlink.target = "${package}/share/superd/services/autocutsel-primary.service";
            # ".config/systemd/user/autocutsel.service".symlink.target = "${package}/share/superd/services/autocutsel.service";
            # ".config/systemd/user/bonsaid.service".symlink.target = "${package}/share/superd/services/bonsaid.service";
            # # ".config/systemd/user/dunst.service".symlink.target = "${package}/share/superd/services/dunst.service";
            # # ".config/systemd/user/mako.service".symlink.target = "${package}/share/superd/services/mako.service";
            # ".config/systemd/user/mmsd-tng.service".symlink.target = "${package}/share/superd/services/mmsd-tng.service";
            # ".config/systemd/user/sxmo_autosuspend.service".symlink.target = "${package}/share/superd/services/sxmo_autosuspend.service";
            # ".config/systemd/user/sxmo_battery_monitor.service".symlink.target = "${package}/share/superd/services/sxmo_battery_monitor.service";
            # ".config/systemd/user/sxmo_conky.service".symlink.target = "${package}/share/superd/services/sxmo_conky.service";
            # ".config/systemd/user/sxmo_desktop_widget.service".symlink.target = "${package}/share/superd/services/sxmo_desktop_widget.service";
            # ".config/systemd/user/sxmo_hook_lisgd.service".symlink.target = "${package}/share/superd/services/sxmo_hook_lisgd.service";
            # ".config/systemd/user/sxmo_menumode_toggler.service".symlink.target = "${package}/share/superd/services/sxmo_menumode_toggler.service";
            # ".config/systemd/user/sxmo_modemmonitor.service".symlink.target = "${package}/share/superd/services/sxmo_modemmonitor.service";
            # ".config/systemd/user/sxmo_networkmonitor.service".symlink.target = "${package}/share/superd/services/sxmo_networkmonitor.service";
            # ".config/systemd/user/sxmo_notificationmonitor.service".symlink.target = "${package}/share/superd/services/sxmo_notificationmonitor.service";
            # ".config/systemd/user/sxmo_soundmonitor.service".symlink.target = "${package}/share/superd/services/sxmo_soundmonitor.service";
            # ".config/systemd/user/sxmo_wob.service".symlink.target = "${package}/share/superd/services/sxmo_wob.service";
            # ".config/systemd/user/sxmo-x11-status.service".symlink.target = "${package}/share/superd/services/sxmo-x11-status.service";
            # ".config/systemd/user/unclutter.service".symlink.target = "${package}/share/superd/services/unclutter.service";
            # ".config/systemd/user/unclutter-xfixes.service".symlink.target = "${package}/share/superd/services/unclutter-xfixes.service";
            # ".config/systemd/user/vvmd.service".symlink.target = "${package}/share/superd/services/vvmd.service";

            # service code further below tells systemd to put ~/.config/sxmo/hooks on PATH, but it puts hooks/bin on PATH instead, so symlink that
            ".config/sxmo/hooks/bin".symlink.target = ".";

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

        sane.user.services = let
          sxmoPath = [ package ] ++ package.runtimeDeps;
          sxmoEnvSetup = ''
            # mimic my sxmo_init.sh a bit. refer to the actual sxmo_init.sh above for details.
            # the specific ordering, and the duplicated profile sourcing, matters.
            export HOME="''${HOME:-/home/colin}"
            export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
            source "$XDG_CONFIG_HOME/sxmo/profile"
            source ${package}/etc/profile.d/sxmo_init.sh
            source "$XDG_CONFIG_HOME/sxmo/profile"
            export PATH="$XDG_CONFIG_HOME/sxmo/hooks:$PATH:${lib.makeBinPath sxmoPath}"
          '';
          sxmoService = name: {
            description = "sxmo ${name}";
            script = ''
              ${sxmoEnvSetup}
              exec sxmo_${name}.sh
            '';
            serviceConfig.Type = "simple";
            serviceConfig.Restart = "always";
            serviceConfig.RestartSec = "20s";
          };
        in {
          # these are defined here, and started mostly in sxmo_hook_start.sh.
          # the ones commented our here are the ones i explicitly no longer use.
          # uncommenting them here *won't* cause them to be auto-started.
          sxmo_autosuspend = sxmoService "autosuspend";
          # sxmo_battery_monitor = sxmoService "battery_monitor";
          sxmo_desktop_widget = sxmoService "hook_desktop_widget";
          sxmo_hook_lisgd = sxmoService "hook_lisgdstart";
          sxmo_menumode_toggler = sxmoService "menumode_toggler";
          sxmo_modemmonitor = sxmoService "modemmonitor";
          # sxmo_networkmonitor = sxmoService "networkmonitor";
          sxmo_notificationmonitor = sxmoService "notificationmonitor";
          # sxmo_soundmonitor = sxmoService "soundmonitor";
          # sxmo_wob = sxmoService "wob";
          sxmo-x11-status = sxmoService "status_xsetroot";

          bonsaid.script = lib.mkBefore sxmoEnvSetup;
        };
      }
    ]))
  ];
}
