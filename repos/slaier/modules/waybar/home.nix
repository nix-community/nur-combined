{ lib, pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      modules-left = [
        "wlr/taskbar"
      ];
      modules-center = [
        "custom/spotify"
      ];
      modules-right = [
        "tray"
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "temperature"
        "clock"
      ];
      "wlr/taskbar" = {
        on-click = "activate";
        on-click-middle = "close";
      };
      "custom/spotify" = {
        format = "{icon} {}";
        return-type = "json";
        max-length = 40;
        escape = true;
        on-click = "${lib.getExe pkgs.playerctl} -p spotify play-pause";
        on-click-right = "killall spotify";
        smooth-scrolling-threshold = 10;
        on-scroll-up = "${lib.getExe pkgs.playerctl} -p spotify next";
        on-scroll-down = "${lib.getExe pkgs.playerctl} -p spotify previous";
        exec = "${lib.getExe (pkgs.callPackage ./mediaplayer.nix {})} --player spotify 2> /dev/null";
        exec-if = "pgrep spotify";
        restart-interval = 2;
      };
      tray = {
        spacing = 10;
      };
      pulseaudio = {
        format = "{icon}: {volume}%";
        format-icons = {
          car = "Car";
          default = "Volume";
          hands-free = "Hands free";
          headphone = "Headphone";
          headset = "Headset";
          phone = "Phone";
          portable = "Portable";
        };
        on-click = "";
        tooltip = false;
      };
      network = {
        interface = "enp5s0";
        format-ethernet = "Ethernet: {bandwidthDownBytes:>}";
        format-disconnected = "Ethernet: Disconnected";
        format-alt = "Ethernet | Interface: {ifname} | IP: {ipaddr}/{cidr}";
        tooltip = false;
        interval = 2;
      };
      cpu = {
        format = "CPU: {usage:>2}%";
      };
      memory = {
        format = "MEM: {percentage:>2}%";
      };
      temperature = {
        format = "GPU {temperatureC}°C";
        hwmon-path = "/sys/class/hwmon/hwmon3/temp1_input";
        critical-threshold = 70;
        tooltip = false;
      };
      clock = {
        interval = 1;
        format = "{:%I:%M %p}";
        format-alt = "{:%A, %B %d - %I:%M:%S %p}";
      };
    };
    style = ./style.css;
    systemd.enable = true;
  };
}
