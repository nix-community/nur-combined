{ sane-lib, ... }:
{
  sane.gui.sxmo = {
    settings = {
      # touch screen
      SXMO_LISGD_INPUT_DEVICE = "/dev/input/by-path/platform-1c2ac00.i2c-event";
      # vol and power are detected correctly by upstream
    };
  };
  # TODO: only populate this if sxmo is enabled?
  sane.user.fs.".config/sxmo/profile" = sane-lib.fs.wantedText ''
    # sourced by sxmo_init.sh
    . sxmo_common.sh

    export SXMO_SWAY_SCALE=1.5
    export SXMO_ROTATION_GRAVITY=12800

    export DEFAULT_COUNTRY=US
    export BROWSER=librewolf

    export SXMO_BG_IMG="$(xdg_data_path sxmo/background.jpg)"
  '';
}
