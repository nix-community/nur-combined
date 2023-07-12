{ pkgs, sane-lib, ... }:
{
  sane.gui.sxmo = {
    settings = {
      ### hardware: touch screen
      SXMO_LISGD_INPUT_DEVICE = "/dev/input/by-path/platform-1c2ac00.i2c-event";
      # vol and power are detected correctly by upstream


      ### preferences
      DEFAULT_COUNTRY = "US";

      SXMO_LOCK_IDLE_TIME = "15";  # how long between screenoff -> lock -> back to screenoff (default: 8)
      # gravity: how far to tilt the device before the screen rotates
      # for a given setting, normal <-> invert requires more movement then left <-> right
      # i.e. the settingd doesn't feel completely symmetric
      # SXMO_ROTATION_GRAVITY default is 16374
      # SXMO_ROTATION_GRAVITY = "12800";  # uncomfortably high
      # SXMO_ROTATION_GRAVITY = "12500";    # kinda uncomfortable when walking
      SXMO_ROTATION_GRAVITY = "12000";
      # test new scales by running `swaymsg -- output DSI-1 scale x.y`
      # SXMO_SWAY_SCALE = "1.5";  # hard to press gPodder icons
      SXMO_SWAY_SCALE = "1.8";
      # SXMO_SWAY_SCALE = "2";
      SXMO_WORKSPACE_WRAPPING = "5";  # how many workspaces. default: 4

      # wvkbd layers:
      # - full
      # - landscape
      # - special  (e.g. coding symbols like ~)
      # - emoji
      # - nav
      # - simple  (like landscape, but no parens/tab/etc; even fewer chars)
      # - simplegrid  (simple, but grid layout)
      # - dialer  (digits)
      # - cyrillic
      # - arabic
      # - persian
      # - greek
      # - georgian
      WVKBD_LANDSCAPE_LAYERS = "landscape,special,emoji";
      WVKBD_LAYERS = "full,special,emoji";
    };
    package = pkgs.sxmo-utils.overrideAttrs (base: {
      postPatch = (base.postPatch or "") + ''
        cat <<EOF >> ./configs/default_hooks/sxmo_hook_start.sh
        # rotate UI based on physical display angle by default
        sxmo_daemons.sh start autorotate sxmo_autorotate.sh
        EOF
      '';
    });
  };
}
