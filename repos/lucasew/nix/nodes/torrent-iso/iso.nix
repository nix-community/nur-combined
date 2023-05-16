let
  impermanenceGit = builtins.fetchGit {
    url = "https://github.com/nix-community/impermanence";
    rev = "4b3000b9bec3a3ce4d5bb7d79abfdd267b5f42ea";
  };
  nixpkgs = builtins.fetchTarball {
    url = "https://releases.nixos.org/nixos/20.09/nixos-20.09.1500.edb26126d98/nixexprs.tar.xz";
    sha256 = "1crsnd7r5zm5sdb1y7swnk9in4qgxjlw548cjkai70i1cz5s6g64";
  };
  pkgs = import nixpkgs {};
in {
  imports = [
    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
    "${impermanenceGit}/nixos.nix"

    # Kernel 5.8 tem melhor performance de IO
  ];
  boot = {
    supportedFilesystems = ["ntfs"];
    kernelPackages = pkgs.linuxPackages_5_8;
  };
  # boot.kernelPackages = pkgs.linuxPackages_5_8;
  fileSystems."/persist" = {
    device = "/dev/mapper/vtoy_persistent";
    fsType = "ext4";
    neededForBoot = true;
  };
  virtualisation.docker.enable = true;
  networking = {
    hostName = "torrent-server";
    firewall.enable = false;
    wireless.enable = false;
    networkmanager.enable = true;
  };
  i18n.defaultLocale = "pt_BR.UTF-8";
  time.timeZone = "America/Sao_Paulo";
  environment.persistence."/persist" = {
    directories = [
      "/var/log"
      "/etc/NetworkManager/system-connections"
      "/srv"
      "/var/lib/docker"
      "/home"
    ];
    files = [
      "/etc/machine-id"
      "/etc/nix/id_rsa"
    ];
  };
  environment.systemPackages = with pkgs; [
    restic
    rclone
    vim
    nano
  ];
  services.openssh = {
    enable = true;
    allowSFTP = true;
    authorizedKeysFiles = [
      "/persist/ssh_authorized_keys"
    ];
    banner = ''
    beep
      
      boop
    '';
    forwardX11 = true;
    hostKeys = [
      {
        bits = 4096;
        path = "/persist/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        path = "/persist/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    passwordAuthentication = false; # TODO: achar um jeito melhor de lidar com isso
  };
}
