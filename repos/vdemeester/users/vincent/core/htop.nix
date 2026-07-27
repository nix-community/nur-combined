{ config, ... }:

{
  programs.htop = {
    enable = true;
    settings = {
      delay = 10;
    } // (with config.lib.htop; leftMeters [
      (bar "AllCPUs2")
      (bar "Memory")
      (bar "Swap")
    ]) // (with config.lib.htop; rightMeters [
      (text "Clock")
      (text "Hostname")
      (text "Tasks")
      (text "LoadAverage")
      (text "Uptime")
      (text "Battery")
      (text "Systemd")
    ]);
  };
}
