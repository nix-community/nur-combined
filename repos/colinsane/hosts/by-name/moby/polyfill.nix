{ ... }:
{
  sane.gui.sxmo = {
    settings = {
      # touch screen
      SXMO_LISGD_INPUT_DEVICE = "/dev/input/by-path/platform-1c2ac00.i2c-event";
      # vol and power are detected correctly by upstream
    };
  };
}
