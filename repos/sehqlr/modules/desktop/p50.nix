{ config, lib, pkgs, ... }: {
    boot.loader.systemd-boot.enable = true;

    time.timeZone = "America/Chicago";

    networking.hostName = "p50";
    networking.useDHCP = false;
    networking.interfaces.enp0s31f6.useDHCP = true;
    networking.interfaces.wlp4s0.useDHCP = true;

    services.jupyterhub.enable = true;
}
