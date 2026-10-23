{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
    ./home.nix
    ./homelab.nix
  ];

  hardware.facter.reportPath = ./facter.json;
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
  ];

  # The current VM boots in BIOS mode; retain an ESP for UEFI compatibility.
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
  };
  boot.kernelParams = [ "console=ttyS0,115200" ];

  networking.hostName = "0xff";
  networking.useDHCP = false;
  systemd.network = {
    enable = true;
    networks."10-eth0" = {
      matchConfig.MACAddress = "00:50:56:68:71:fc";
      address = [
        "144.91.107.232/18"
        "2a02:c207:2366:9598::1/64"
      ];
      routes = [
        { Gateway = "144.91.64.1"; }
        {
          Gateway = "fe80::1";
          GatewayOnLink = true;
        }
      ];
      networkConfig = {
        DNS = [
          "195.179.224.53"
          "209.126.15.53"
        ];
        IPv6AcceptRA = false;
      };
    };
  };
  services.tailscale.enable = true;

  users.users.avy.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGfR13myvqgdgcxqvpEOoftPCIIhIgx9/9gDFZ2+lT9 sakg.dev.14@gmail.com"
  ];

  time.timeZone = lib.mkForce "Europe/Berlin";
  system.stateVersion = "26.11";
}
