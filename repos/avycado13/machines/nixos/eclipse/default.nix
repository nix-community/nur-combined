{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./homelab.nix
  ];

  # Boot configuration (GRUB, BIOS + EFI hybrid)
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "/dev/vda";
  };
  boot.tmp.cleanOnBoot = true;

  # /boot lives on the root partition (only /boot/efi is separate), so
  # nix-mineral's separate-partition hardening for it doesn't apply.
  nix-mineral.filesystems.normal."/boot".enable = false;

  # Serial console
  boot.kernelParams = [ "console=ttyS0,115200" ];

  networking = {
    hostName = "eclipse";
    useDHCP = true;
  };

  # The VM's DHCP DNS proxy (10.0.2.3) fails to resolve with DNSSEC enabled.
  # Keep DHCP for addresses/routes, but use working public resolvers.
  systemd.network.networks."99-ethernet-default-dhcp" = {
    networkConfig.DNS = [
      "1.1.1.1"
      "9.9.9.9"
    ];
    dhcpV4Config.UseDNS = false;
    dhcpV6Config.UseDNS = false;
  };

  users.users.avy.extraGroups = [
    "wheel"
    "docker"
  ];

  system.stateVersion = "25.05";
}
