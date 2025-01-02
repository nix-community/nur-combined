{ ... }:
{
  sane.programs.conky = {
    sandbox.net = "clearnet";  #< for the scripts it calls (weather)
    sandbox.extraPaths = [
      "/sys/class/power_supply"
      "/sys/devices"  # needed by sane-sysload
      # "/sys/devices/cpu"
      # "/sys/devices/system"
    ];
    sandbox.whitelistWayland = true;

    suggestedPrograms = [
      "sane-sysload"
      "sane-weather"
    ];

    fs.".config/conky/conky.conf".symlink.target = ./conky.conf;

    services.conky = {
      description = "conky dynamic desktop background";
      partOf = [ "graphical-session" ];
      command = "conky";
    };
  };
}
