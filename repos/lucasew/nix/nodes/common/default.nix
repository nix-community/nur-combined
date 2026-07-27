{
  self,
  pkgs,
  lib,
  ...
}:
let
  inherit (self) inputs;
  inherit (lib) mkDefault;
in
{
  imports = [
    ../bootstrap
    ./cachix.nix
    ./hold-gc.nix

    ./ansible-python.nix
    ./services

    ./kvm.nix
    ./lvm.nix
    ./nix-ld.nix
    ./nix-index-database.nix
    ./sops.nix
    ./tuning.nix
    ./unstore.nix
    ./workusers.nix
  ];

  boot.supportedFilesystems = [
    "nfs"
    "btrfs"
  ];

  services.lvm.enable = mkDefault false;

  services.phpelo.enable = false;

  programs.fuse.userAllowOther = true;

  services.cloud-savegame = {
    enableVerbose = true;
    enableGit = true;
    enableBacklink = true;
    settings = {
      search = {
        paths = [
          "~"
          "~/.steam/steam/steamapps/compatdata/"
          "~/.config"
          "~/.nix-wine"
          "~/.wine"
        ];
        ignore = [
          "/home/lucasew/WORKSPACE"
          "/home/lucasew/TMP2"
          "/run/media"
        ];
        extra_homes = [ "/run/media/lucasew/Dados/DADOS/Lucas" ];
      };

      flatout-2 = {
        installdir = [
          "~/.local/share/Steam/steamapps/common/FlatOut2"
          "/run/media/lucasew/Dados/DADOS/Jogos/FlatOut 2"
        ];
      };

      farming-simulator-2013 = {
        ignore_mods = true;
      };
    };
  };

  services.unstore = {
    # enable = true;
    paths = [ "flake.nix" ];
  };

  boot.loader.grub.memtest86.enable = true;

  virtualisation.docker.enable = lib.mkDefault true;

  environment = {
    systemPackages = with pkgs; [
      bubblewrap
      ts # simple queue system
      rlwrap
      wget
      curl
      unrar
      zip
      direnv
      pciutils
      usbutils
      htop
      lm_sensors
      fastfetch
      lls # like netstat
      cached-nix-shell
    ];
  };
  cachix.enable = true;

  services.smartd = {
    enable = lib.mkDefault true;
    autodetect = true;
    notifications.test = true;
  };
}
