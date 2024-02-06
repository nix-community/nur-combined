{ lib, config, ... }:
with lib; {
  imports = [
    ./doas.nix
    ./encrypted-dns.nix
    ./flatpak.nix
    ./nix.nix
    ./nvidia.nix
    ./sound.nix
    ./zfs.nix
  ];

  options.eownerdead.recommended = mkEnableOption (mdDoc ''
    Settings I recommended in most cases.
  '');

  config = mkIf config.eownerdead.recommended {
    eownerdead = {
      doas = mkDefault true;
      encryptedDns = mkDefault true;
      nix = mkDefault true;
    };

    users.mutableUsers = false;

    services.envfs.enable = true;
  };
}

