{
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hardware-configuration.nix
  ];

  # Proxmox manages the host's bootloader; this is an LXC container.
  boot.isContainer = true;
  boot.loader.grub.enable = false;

  networking = {
    hostName = "nest";
    useDHCP = true;
    hostId = "80bc3874";
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
  services.tailscale = {
    interfaceName = "userspace-networking";
    extraSetFlags = [ "--hostname=nest" ];
  };

  systemd.services.zfs-mount.enable = false;
  systemd.services.zfs-share.enable = false;
  systemd.services.zfs-zed.enable = false;
  systemd.mounts = [
    {
      where = "/sys/kernel/debug";
      enable = false;
    }
  ];

  system.stateVersion = "25.11";
}
