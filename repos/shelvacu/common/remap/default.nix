{
  pkgs,
  lib,
  vaculib,
  vacuModuleType,
  ...
}:
let
  menu2meta = pkgs.runCommandCC "menu2meta" {
    meta.mainProgram = "menu2meta";
  } ''
    mkdir -p $out/bin
    cc -Wall -O2 ${vaculib.path ./menu2meta.c} -o $out/bin/menu2meta
  '';
  museDashNumpad = left:
    let
      name = "museDashNumpad-${if left then "left" else "right"}";
    in
    pkgs.runCommandCC name {
      meta.mainProgram = name;
    } ''
      mkdir -p $out/bin
      cc -Wall -O2 ${lib.optionalString left "-DSIDE_LEFT=1"} ${vaculib.path ./museDashNumpad.c} -o $out/bin/${name}
    '';
  combinedOutputConfigObject = {
    NAME = "Interception Tools - combined output";
    BUSTYPE = "BUS_VIRTUAL";
    EVENTS = {
      EV_SYN = [
        "SYN_REPORT"
        "SYN_CONFIG"
        "SYN_MT_REPORT"
        "SYN_DROPPED"
      ];
      EV_MSC = [ "MSC_SCAN" ];
      EV_LED = [ "LED_NUML" "LED_CAPSL" "LED_SCROLLL" ];
      EV_REP = {
        REP_DELAY = 250;
        REP_PERIOD = 33;
      };
      EV_KEY = vaculib.listOfLines { } ''
        KEY_ESC
        KEY_1
        KEY_2
        KEY_3
        KEY_4
        KEY_5
        KEY_6
        KEY_7
        KEY_8
        KEY_9
        KEY_0
        KEY_MINUS
        KEY_EQUAL
        KEY_BACKSPACE
        KEY_TAB
        KEY_Q
        KEY_W
        KEY_E
        KEY_R
        KEY_T
        KEY_Y
        KEY_U
        KEY_I
        KEY_O
        KEY_P
        KEY_LEFTBRACE
        KEY_RIGHTBRACE
        KEY_ENTER
        KEY_LEFTCTRL
        KEY_A
        KEY_S
        KEY_D
        KEY_F
        KEY_G
        KEY_H
        KEY_J
        KEY_K
        KEY_L
        KEY_SEMICOLON
        KEY_APOSTROPHE
        KEY_GRAVE
        KEY_LEFTSHIFT
        KEY_BACKSLASH
        KEY_Z
        KEY_X
        KEY_C
        KEY_V
        KEY_B
        KEY_N
        KEY_M
        KEY_COMMA
        KEY_DOT
        KEY_SLASH
        KEY_RIGHTSHIFT
        KEY_KPASTERISK
        KEY_LEFTALT
        KEY_SPACE
        KEY_CAPSLOCK
        KEY_F1
        KEY_F2
        KEY_F3
        KEY_F4
        KEY_F5
        KEY_F6
        KEY_F7
        KEY_F8
        KEY_F9
        KEY_F10
        KEY_F11
        KEY_F12
        KEY_F13
        KEY_F14
        KEY_F15
        KEY_F16
        KEY_F17
        KEY_F18
        KEY_F19
        KEY_F20
        KEY_F21
        KEY_F22
        KEY_F23
        KEY_F24
        KEY_NUMLOCK
        KEY_SCROLLLOCK
        KEY_KP7
        KEY_KP8
        KEY_KP9
        KEY_KPMINUS
        KEY_KP4
        KEY_KP5
        KEY_KP6
        KEY_KPPLUS
        KEY_KP1
        KEY_KP2
        KEY_KP3
        KEY_KP0
        KEY_KPDOT
        KEY_KPENTER
        KEY_RIGHTCTRL
        KEY_KPSLASH
        KEY_SYSRQ
        KEY_RIGHTALT
        KEY_HOME
        KEY_UP
        KEY_PAGEUP
        KEY_LEFT
        KEY_RIGHT
        KEY_END
        KEY_DOWN
        KEY_PAGEDOWN
        KEY_INSERT
        KEY_DELETE
        KEY_MUTE
        KEY_VOLUMEDOWN
        KEY_VOLUMEUP
        KEY_POWER
        KEY_KPEQUAL
        KEY_PAUSE
        KEY_KPCOMMA
        KEY_HANGEUL
        KEY_HANJA
        KEY_YEN
        KEY_LEFTMETA
        KEY_RIGHTMETA
        KEY_COMPOSE
        KEY_STOP
        KEY_AGAIN
        KEY_PROPS
        KEY_UNDO
        KEY_FRONT
        KEY_COPY
        KEY_OPEN
        KEY_PASTE
        KEY_FIND
        KEY_CUT
        KEY_HELP
        KEY_CALC
        KEY_SLEEP
        KEY_WWW
        KEY_COFFEE
        KEY_BACK
        KEY_FORWARD
        KEY_EJECTCD
        KEY_NEXTSONG
        KEY_PLAYPAUSE
        KEY_PREVIOUSSONG
        KEY_STOPCD
        KEY_REFRESH
        KEY_EDIT
        KEY_SCROLLUP
        KEY_SCROLLDOWN
        KEY_KPLEFTPAREN
        KEY_KPRIGHTPAREN
      '';
    };
  };
  combinedOutputConfigFile = pkgs.writers.writeYAML "interception-tools-output-device.yaml" combinedOutputConfigObject;
  museDashDeviceScript = pkgs.writeScriptBin "museDashDevice" ''
    set -euo pipefail

    devNodeReal="$(readlink -f -- "$DEVNODE")"
    eventName="''${devNodeReal##*/}"
    phys="$(<"/sys/class/input/$eventName/device/phys")"
    declare -p DEVNODE devNodeReal eventName phys || true
    declare numpadBin
    if [[ $phys == "usb-0000:c5:00.3-2.1.1/input0" ]]; then
      numpadBin=${lib.getExe (museDashNumpad true)}
    elif [[ $phys == "usb-0000:c5:00.3-2.1.3/input0" ]]; then
      numpadBin=${lib.getExe (museDashNumpad false)}
    else
      echo "warn: unrecognized phys $phys" >&2
      exit 0
    fi
    intercept -g "$DEVNODE" | "$numpadBin" | mux -o main
  '';
  udevmonConfigObject = [
    { CMD = "mux -c main"; }
    { JOB = [
      ''echo "running job for mux main"''
      ''mux -i main | uinput -c ${combinedOutputConfigFile}''
    ]; }
    {
      JOB = [
        ''echo "$DEVNODE: running job for muse dash numpad"''
        (lib.getExe museDashDeviceScript)
      ];
      DEVICE = {
        PRODUCT = 1;
        VENDOR = 5050;
      };
    }
    {
      JOB = ''echo "$DEVNODE: ignoring because it has EV_ABS"'';
      DEVICE.EVENTS.EV_ABS = [ ];
    }
    {
      JOB = ''echo "$DEVNODE: ignoring because it has EV_REL"'';
      DEVICE.EVENTS.EV_REL = [ ];
    }
    {
      JOB = [
        ''echo "$DEVNODE: running job for keyboard with CAPSLOCK and/or COMPOSE (menu)"''
        ''intercept -g "$DEVNODE" | caps2esc -m 1 | ${lib.getExe menu2meta} | mux -o main''
      ];
      DEVICE.EVENTS.EV_KEY = [ "KEY_CAPSLOCK" "KEY_COMPOSE" ];
    }
  ];
  udevmonConfigFile = pkgs.writers.writeYAML "udevmonConfig.yaml" udevmonConfigObject;
in
lib.optionalAttrs (vacuModuleType == "nixos") {
  config = {
    systemd.services."interception-tools" = {
      description = "Interception tools for remapping inputs, from <vacu>/common/remap";
      path = [
        pkgs.bash
        pkgs.interception-tools
        pkgs.interception-tools-plugins.caps2esc
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.interception-tools}/bin/udevmon -c ${udevmonConfigFile}";
        Nice = -10;
      };
    };
  };
}
