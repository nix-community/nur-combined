{ lib, config, ... }:
with lib;
{
  imports = [
    ./doas.nix
    ./encrypted-dns.nix
    ./flatpak.nix
    ./intel-graphics.nix
    ./libvirtd.nix
    ./nix.nix
    ./nvidia.nix
    ./sound.nix
    ./tor.nix
    ./zfs.nix
    ./zram.nix
  ];

  options.eownerdead.recommended = mkEnableOption (mdDoc ''
    Settings I recommended in most cases.
  '');

  config = mkIf config.eownerdead.recommended {
    eownerdead = {
      doas = mkDefault true;
      encryptedDns = mkDefault true;
      nix = mkDefault true;
      zram = mkDefault true;
    };

    users.mutableUsers = false;

    # networking.nftables.enable = true; # Instead of iptables

    services.envfs.enable = true;
  };
}
