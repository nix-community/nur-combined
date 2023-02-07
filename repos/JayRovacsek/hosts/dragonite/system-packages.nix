{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    vim
    exfat
    cifs-utils
    dnsutils
    zfs
    pciutils
    nvidia-docker
    lm_sensors
    hddtemp
  ];
}
