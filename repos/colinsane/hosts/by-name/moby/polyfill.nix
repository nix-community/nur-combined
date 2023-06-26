{ pkgs, sane-lib, ... }:
{
  sane.gui.sxmo = {
    settings = {
      # touch screen
      SXMO_LISGD_INPUT_DEVICE = "/dev/input/by-path/platform-1c2ac00.i2c-event";
      # vol and power are detected correctly by upstream

      # preferences
      # N.B. some deviceprofiles explicitly set SXMO_SWAY_SCALE, overwriting what we put here.
      SXMO_SWAY_SCALE = "1.5";
      SXMO_ROTATION_GRAVITY = "12800";
      DEFAULT_COUNTRY = "US";
      BROWSWER = "librewolf";
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
