{self, pkgs, lib, unpackedInputs, ...}:
let
  inherit (self) inputs;
  inherit (lib) mkDefault;
in
{
  imports = [
    ../bootstrap
    ../../modules/cachix/system.nix
    ../../modules/hold-gc/system.nix
    "${unpackedInputs.simple-dashboard}/nixos-module.nix"

    ./ansible-python.nix
    ./bash
    ./cf-torrent.nix
    ./cloud-savegame.nix
    ./cockpit-extra.nix
    ./hosts.nix
    ./invidious.nix
    ./jellyfin.nix
    ./kvm.nix
    ./libreddit.nix
    ./lvm.nix
    ./magnetico.nix
    ./netusage.nix
    ./nginx-root-domain.nix
    ./nginx.nix
    ./nix-index-database.nix
    ./p2k.nix
    ./sops.nix
    ./telegram_sendmail.nix
    ./tmux
    ./transmission.nix
    ./tt-rss.nix
    ./tuning.nix
    ./unstore.nix
    ./user.nix
  ];

  services.lvm.enable = mkDefault false;

  programs.fuse.userAllowOther = true;

  services.cloud-savegame = {
    enableVerbose = true;
    enableGit = true;
    settings = {
      search = {
        paths = [ "~" ];
        extra_homes = [ "/run/media/lucasew/Dados/DADOS/Lucas" ];
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
      rlwrap
      wget
      curl
      unrar
      direnv
      pciutils
      usbutils
      htop
      lm_sensors
      neofetch
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
