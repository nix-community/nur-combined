{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.sane-input-handler;
  doExec = inputName: transitions: {
    type = "exec";
    command = [
      "setsid" "-f"  #< fork before invoking the input handler, else it runs synchronously
      "sane-input-handler"
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
in
{
  sane.programs.sane-input-handler = {
    configOption = with lib; mkOption{
      default = {};
      type = types.submodule {
        options = {
          devices = mkOption {
            type = types.listOf types.str;
            default = [
              "0:1:Power_Button"  #< Thinkpad power button
              "1:1:AT_Translated_Set_2_keyboard"  #< Thinkpad volume buttons (plus all its other buttons)
              "0:0:axp20x-pek"  #< Pinephone power button
              "1:1:1c21800.lradc"  #< Pinephone volume buttons
            ];
            description = ''
              list of devices which we should listen for special inputs from.
              find these names with:
              `swaymsg -t get_inputs --raw | jq 'map(.identifier)'`
            '';
          };
        };
      };
    };
    packageUnwrapped = pkgs.static-nix-shell.mkBash {
      pname = "sane-input-handler";
      srcRoot = ./.;
      pkgs = {
        inherit (pkgs) coreutils killall playerctl procps sane-open-desktop util-linux wireplumber;
        sway = config.sane.programs.sway.package.sway-unwrapped;
      };
    };
    suggestedPrograms = [
      "bonsai"
      "killall"
      "playerctl"
      "procps"
      "sane-open-desktop"
      "sway"
      "wireplumber"
      "wvkbd"
    ];
    sandbox.method = "bwrap";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  #< to launch applications
    sandbox.extraRuntimePaths = [ "sway" ];
    sandbox.extraConfig = [
      "--sane-sandbox-keep-namespace" "pid"
    ];
  };

  # sane.programs.actkbd = {
  #   fs.".config/actkbd/actkbd.conf".symlink.text = ''
  #     114:key::bonsaictl -e voldown_pressed
  #     114:rel::bonsaictl -e voldown_released
  #     115:key::bonsaictl -e volup_pressed
  #     115:rel::bonsaictl -e volup_released
  #     # note that power might be on its own /dev/input/event* device separate from the volume buttons
  #     116:key::bonsaictl -e power_pressed
  #     116:rel::bonsaictl -e power_released
  #   '';
  #   services.actkbd = {
  #     # TODO: apparently i need one instance per /dev/input, which also means i need udev, etc.
  #     description = "actkbd: keyboard input mapping";
  #     after = [ "graphical-session.target" ];
  #     wantedBy = [ "graphical-session.target" ];

  #     serviceConfig.ExecStart = "${config.sane.programs.actkbd.package}/bin/actkbd -c /home/colin/.config/actkbd/actkbd.conf";
  #   };
  # };

  # TODO: duplicated sandboxing here is just ugly
  sane.programs.bonsai.sandbox = lib.mkIf cfg.enabled (
    builtins.removeAttrs cfg.sandbox [ "method" ]  #< else infinite recursion
  );
  sane.programs.bonsai.config.transitions = lib.mkIf cfg.enabled (friendlyToBonsai {
    # map sequences of "events" to an argument to pass to sane-input-handler

    # map: power (short), power (short) x2, power (long)
    power_pressed.timeout.ms = 900; # press w/o release. this is a long timeout because it's tied to the "kill window" action.
    power_pressed.timeout.trigger = "powerhold";
    power_pressed.power_released.timeout.trigger = "powerbutton_one";
    power_pressed.power_released.timeout.ms = 300;
    power_pressed.power_released.power_pressed.trigger = "powerbutton_two";
    # map power (short) -> volup/voldown
    power_pressed.power_released.volup_pressed.trigger = "powerbutton_volup";
    power_pressed.power_released.voldown_pressed.trigger = "powerbutton_voldown";

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
  });

  sane.programs.sway.config.extra_lines = lib.mkIf cfg.enabled (
    ''
      # bindsym --input-device=... :
      # i wish to route certain events both to bonsai and/or the application
      #   (rather, if there is an application which would receive them, send them, else re-route to bonsai).
      # bindsym --input-device=* SWALLOWS all events: it sends them to bonsaid and NOT any gui app.
      # bindsym --input-device=<dev> DOESN'T SWALLOW EVENTS: it sends them to BOTH places (yay!).
      # however, this is considered a BUG. i am relying on a bug here that may be fixed in future sway versions:
      # - <https://github.com/swaywm/sway/issues/6961>
      # if so, migrate this to an evdev daemon, such as `evdevremapkeys` or `actkbd`
    '' + lib.concatStringsSep "\n" (lib.forEach cfg.config.devices (dev: ''
      bindsym --locked --input-device=${dev} --no-repeat XF86PowerOff exec bonsaictl -e power_pressed
      bindsym --locked --input-device=${dev} --release XF86PowerOff exec bonsaictl -e power_released
      bindsym --locked --input-device=${dev} --no-repeat XF86AudioRaiseVolume exec bonsaictl -e volup_pressed
      bindsym --locked --input-device=${dev} --release XF86AudioRaiseVolume exec bonsaictl -e volup_released
      bindsym --locked --input-device=${dev} --no-repeat XF86AudioLowerVolume exec bonsaictl -e voldown_pressed
      bindsym --locked --input-device=${dev} --release XF86AudioLowerVolume exec bonsaictl -e voldown_released
    ''))
  );
}
