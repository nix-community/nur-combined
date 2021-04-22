{ config, lib, pkgs, ... }: {
    boot.loader.systemd-boot.enable = true;
    networking.hostName = "p50";

    time.timeZone = "America/Chicago";

    networking.useDHCP = false;
    networking.interfaces.enp0s31f6.useDHCP = true;
    networking.interfaces.wlp4s0.useDHCP = true;
}
