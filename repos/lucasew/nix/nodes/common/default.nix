{self, pkgs, lib, ...}:
let
  inherit (self) inputs;
  inherit (lib) mkDefault;
in
{
  imports = [
    ../bootstrap
    ./cachix.nix
    ./hold-gc.nix
    (inputs.simple-dashboard + /nixos-module.nix)

    ./ansible-python.nix
    ./services

    ./hosts.nix
    ./kvm.nix
    ./lvm.nix
    ./nginx-root-domain.nix
    ./nginx.nix
    ./nix-index-database.nix
    ./sops.nix
    ./tmux
    ./tuning.nix
    ./unstore.nix
    ./user.nix
    ./postgres-backup.nix
  ];

  boot.supportedFilesystems = [ "nfs" "btrfs" ];

  services.lvm.enable = mkDefault false;

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
        extra_homes = [
          "/run/media/lucasew/Dados/DADOS/Lucas"
        ];
      };

      flatout-2 = {
        installdir= [ "~/.local/share/Steam/steamapps/common/FlatOut2" "/run/media/lucasew/Dados/DADOS/Jogos/FlatOut 2"];
      };

      farming-simulator-2013 = {
        ignore_mods = true;
      };
    };
  };



  services.unstore = {
    # enable = true;
    paths = [
      "flake.nix"
    ];
  };

  boot.loader.grub.memtest86.enable = true;

  virtualisation.docker = {
    enable = true;
    # dockerSocket.enable = true;
    # dockerCompat = true;
    enableNvidia = true;
  };

  environment = {
    systemPackages = with pkgs; [
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
      neofetch
      lls # like netstat
    ];
  };
  cachix.enable = true;

  services.smartd = {
    enable = true;
    autodetect = true;
    notifications.test = true;
  };

  services.nginx.appendHttpConfig = ''
    error_log stderr;
    access_log syslog:server=unix:/dev/log combined;
  '';
}
