{ config, pkgs, lib, ... }:

{
  boot = {
    # Quiet console at startup.
    kernelParams = [ "quiet" "vga=current" ];
    # Assume /dev/sda is an SSD, which doesn't need an IO queue scheduler.
    postBootCommands = "echo none > /sys/block/sda/queue/scheduler";
  };

  # /tmp on tmpfs.
  fileSystems."/tmp" = {
    fsType = "tmpfs";
    device = "tmpfs";
    options = [ "mode=1777" "strictatime" "nosuid" "nodev" "size=12g" ];
  };

  networking = {
    # Use NetworkManager for networking.
    networkmanager.enable = true;

    # Extra hosts.
    extraHosts = ''
      91.205.173.25 argon
    '';
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # Improve boot time by not waiting for the network and time sync to come up.
  systemd.services."network-manager" = {
    wantedBy = lib.mkForce [ ];
  };
  systemd.services."systemd-timesyncd" = {
    wantedBy = lib.mkForce [ ];
  };
  # Yes, this is a hack.
  services.xserver.displayManager.sddm.setupScript = "${pkgs.systemd}/bin/systemctl start network-manager systemd-timesyncd";

  hardware = {
    # Enable PulseAudio.
    pulseaudio.enable = true;

    # 32 bit compatibility for Steam.
    opengl.driSupport32Bit = true;
    pulseaudio.support32Bit = true;
  };

  # Systemd stop job timeout.
  systemd.extraConfig = ''
    DefaultTimeoutStartSec=10s
    DefaultTimeoutStopSec=10s
  '';

  # services.udisks2.enable = true;
}
