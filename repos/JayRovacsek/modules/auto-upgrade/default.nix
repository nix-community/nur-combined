{ config, ... }: {
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    rebootWindow = {
      lower = "03:00";
      upper = "04:00";
    };
    dates = "daily";
    flags = [ "--flake" ".#${config.networking.hostName}" ];
  };
}
