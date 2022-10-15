{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.udev;

  rules = pkgs.writeTextFile {
    name = "ioschedulers";
    text = ''
      # set scheduler for NVMe
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
      # set scheduler for SSD and eMMC
      ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
      # set scheduler for rotating disks
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    '';
    destination = "/etc/udev/rules.d/60-ioschedulers.rules";
  };
in {
  options = {
    services.udev = {
      optimalSchedulers = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Use optimal I/O schedulers from https://wiki.archlinux.org/index.php/Improving_performance#Changing_I/O_scheduler.
        '';
      };
    };
  };

  config = mkIf cfg.optimalSchedulers {
    services.udev.packages = [ rules ];
  };
}
