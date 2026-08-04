{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    inputs.lanzaboote.nixosModules.lanzaboote
    ./avahi.nix
    ./encrypted-dns.nix
    ./fscrypt.nix
    ./gnome.nix
    ./hardening.nix
    ./intel-graphics.nix
    ./libvirtd.nix
    ./nix.nix
    ./nvidia.nix
    ./podman.nix
    ./run0.nix
    ./sound.nix
    ./zfs.nix
    ./zram.nix
  ];

  options.eownerdead.recommended = mkEnableOption (mdDoc ''
    Settings I recommended in most cases.
  '');

  config = mkIf config.eownerdead.recommended {
    eownerdead = {
      avahi = mkDefault true;
      run0 = mkDefault true;
      encryptedDns = mkDefault true;
      nix = mkDefault true;
      zram = mkDefault true;
    };

    boot.lanzaboote = {
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys.enable = true;
    };

    users.mutableUsers = false;

    networking = {
      useNetworkd = true;
      nftables.enable = true; # Instead of iptables
    };

    # HACK: https://github.com/NixOS/nixpkgs/issues/247608
    systemd.network.wait-online.enable = false;
    time.hardwareClockInLocalTime = true; # compatibility with Windows

    services.envfs.enable = true;

    programs.ssh.package = pkgs.openssh_hpn;

    system.etc.overlay = {
      enable = true;
      mutable = true;
    };

    boot.initrd.systemd.enable = true; # Required by overlay etc

    home-manager = {
      backupFileExtension = "backup";
      extraSpecialArgs = {
        inherit inputs;
      };
      sharedModules = [ { imports = [ ../hm ]; } ];
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
