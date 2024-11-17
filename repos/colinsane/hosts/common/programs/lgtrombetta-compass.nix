{ ... }:
{
  sane.programs.lgtrombetta-compass = {
    # example compass.conf, calibrated well
    # [settings]
    # version = 0.4.0
    # theme = dark
    #
    # [device]
    # name = AF8133J
    # magn_x_offset = 281
    # magn_y_offset = -35
    # magn_z_offset = 537
    #
    persist.byStore.plaintext = [
      ".config/compass"
    ];
    fs.".config/compass.conf".symlink.target = "compass/compass.conf";

    sandbox.extraPaths = [
      "/sys/bus/iio/devices"
      "/sys/devices"
    ];
  };
}
