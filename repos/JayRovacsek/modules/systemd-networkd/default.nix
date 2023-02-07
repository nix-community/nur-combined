{ lib, ... }: {
  networking = {
    useNetworkd = true;
    dhcpcd.enable = false;
  };

  networking.networkmanager.enable = false;

  imports = [ ./networks.nix ];

  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
}
