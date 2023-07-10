{ pkgs, sane-lib, ... }:
{
  sane.gui.sxmo = {
    settings = {
      ### hardware: touch screen
      SXMO_LISGD_INPUT_DEVICE = "/dev/input/by-path/platform-1c2ac00.i2c-event";
      # vol and power are detected correctly by upstream

      ### preferences
      # SXMO_SWAY_SCALE = "1.5";
      SXMO_SWAY_SCALE = "2";
      SXMO_ROTATION_GRAVITY = "12800";
      SXMO_LOCK_IDLE_TIME = "15";  # how long between screenoff -> lock -> back to screenoff
      DEFAULT_COUNTRY = "US";
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
      WVKBD_LAYERS = "full,special,emoji";
      WVKBD_LANDSCAPE_LAYERS = "landscape,special,emoji";
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
