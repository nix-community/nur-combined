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

  # trigger ${button}_hold_N repeatedly for as long as ${button} is held.
  # ${holdTimes[N]}: how long to wait after the N'th event before firing the event again.
  #   if the holdTimes list has fewer items than `maxHolds`, then the list is extended by duplicating its last item.
  recurseHold = button: { count ? 1, maxHolds ? 8, holdTimes ? [ 500 2500 ] }@opts: {
    trigger = "${button}_hold_${builtins.toString count}";
    ms = builtins.elemAt holdTimes (count - 1);
  } // lib.optionalAttrs (count < maxHolds) {
    timeout = recurseHold button (opts // { count = count+1; holdTimes = holdTimes ++ [(lib.last holdTimes)]; });
    # end the hold -> back to root state
    # take care to omit this on the last hold though, so that there's always a strictly delay-driven path back to root
    "${button}_released".terminal = true;
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
              "1:1:gpio-keys"  #< Pinephone Pro power button
              "1:1:adc-keys"  #< Pinephone Pro volume buttons
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
    packageUnwrapped = pkgs.sane-input-handler.override {
      sway = config.sane.programs.sway.package;
    };
    suggestedPrograms = [
      "bonsai"
      # dependencies which get pulled in unconditionally:
      "killall"
      "playerctl"
      "procps"  #< TODO: reduce to just those parts of procps which are really needed
      "sane-open"
      # "sway"  #< TODO: circular dependency :-(
      "wireplumber"
      # optional integrations:
      "megapixels"
      "rofi"
      "xdg-terminal-exec"
      "wvkbd"
    ];
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  #< to launch applications
    # sandbox.whitelistMpris.controlPlayers = true;
    # sandbox.whitelistPortal = [
    #   "DynamicLauncher"
    # ];
    sandbox.whitelistSystemctl = true;  #< to restart bonsaid on failure
    sandbox.extraRuntimePaths = [ "sway" ];
    sandbox.keepPidsAndProc = true;  #< for toggling the keyboard
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

  #     serviceConfig.ExecStart = "${lib.getExe config.sane.programs.actkbd.package} -c /home/colin/.config/actkbd/actkbd.conf";
  #   };
  # };

  # TODO: duplicated sandboxing here is just ugly
  sane.programs.bonsai.sandbox = lib.mkIf cfg.enabled (
    builtins.removeAttrs cfg.sandbox [ "method" ]  #< else infinite recursion
  );
  sane.programs.bonsai.config.transitions = lib.mkIf cfg.enabled (friendlyToBonsai {
    # map sequences of "events" to an argument to pass to sane-input-handler

    # map: power (tap), power (tap) x2
    power_pressed.power_released.trigger = "power_tap_1";
    power_pressed.power_released.timeout.ms = 825;  # max time within which a second power press will be recognized
    power_pressed.power_released.power_pressed.power_released.trigger = "power_tap_2";
    # map power (hold), power tap -> hold:
    power_pressed.timeout.trigger = "power_hold";
    power_pressed.timeout.ms = 500;
    power_pressed.power_released.power_pressed.timeout.trigger = "power_tap_1_hold";
    power_pressed.power_released.power_pressed.timeout.ms = 875;  # this is a long timeout because it's tied to the "kill window" action.

    # map: power (tap) -> volup/voldown
    power_pressed.power_released.volup_pressed.trigger = "power_then_volup";
    power_pressed.power_released.voldown_pressed.trigger = "power_then_voldown";

    # map: power + volup/voldown
    power_pressed.volup_pressed.trigger = "power_and_volup";
    power_pressed.voldown_pressed.trigger = "power_and_voldown";

    # map: volume taps and holds
    volup_pressed.trigger = "volup_start";
    volup_pressed.volup_released.trigger = "volup_tap_1";
    volup_pressed.timeout = recurseHold "volup" {};

    voldown_pressed.trigger = "voldown_start";
    voldown_pressed.voldown_released.trigger = "voldown_tap_1";
    voldown_pressed.timeout = recurseHold "voldown" {};
  });

  sane.programs.sway.sandbox.extraRuntimePaths = lib.mkIf cfg.enabled [ "bonsai" ];
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
