# doesn't actually *enable* anything,
# but sets up any modules such that if they *were* enabled, they'll act as expected.
{ pkgs, ... }:
{
  sane.gui.sxmo = {
    greeter = "greetd-sway-gtkgreet";
    noidle = true;  #< power button requires 1s hold, which makes it impractical to be dealing with.
    settings = {
      # XXX: make sure the user is part of the `input` group!
      SXMO_LISGD_INPUT_DEVICE = "/dev/input/by-id/usb-Wacom_Co._Ltd._Pen_and_multitouch_sensor-event-if00";
      # these identifiers are from `swaymsg -t get_inputs`
      SXMO_VOLUME_BUTTON = "1:1:AT_Translated_Set_2_keyboard";
      # SXMO_VOLUME_BUTTON = "none";
      # N.B.: thinkpad's power button requires a full second press to do anything
      SXMO_POWER_BUTTON = "0:1:Power_Button";
      # SXMO_POWER_BUTTON = "none";
      SXMO_DISABLE_LEDS = "1";
      SXMO_UNLOCK_IDLE_TIME = "120";  # default
      # sxmo tries to determine device type from /proc/device-tree/compatible,
      # but that doesn't seem to exist on NixOS?  (or maybe it just doesn't exist
      # on non-aarch64 builds).
      # the device type informs (at least):
      # - SXMO_WIFI_MODULE
      # - SXMO_RTW_SCAN_INTERVAL
      # - SXMO_TOUCHSCREEN_ID
      # - SXMO_MONITOR
      # - SXMO_ALSA_CONTROL_NAME
      # - SXMO_SWAY_SCALE
      # see <repo:mil/sxmo-utils:scripts/deviceprofiles>
      # SXMO_DEVICE_NAME = "pine64,pinephone-1.2";
      # if sxmo doesn't know the device, it can't decide whether to use one_button or three_button mode
      #   and so it just wouldn't handle any button inputs (sxmo_hook_inputhandler.sh not on path)
      SXMO_DEVICE_NAME = "three_button_touchscreen";
    };
    package = (pkgs.sxmo-utils.override { preferSystemd = true; }).overrideAttrs (base: {
      postPatch = (base.postPatch or "") + ''
        # after volume-button navigation mode, restore full keyboard functionality
        cp ${./xkb_mobile_normal_buttons} ./configs/xkb/xkb_mobile_normal_buttons
      '';
    });
  };
}
