{pkgs, ...}:
let
  adm = "lucasew";
in
{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>
  ];
  nixpkgs.config.allowUnfree = true;
  nix = {
    trustedUsers = [ adm "@wheel"];
    package = pkgs.nixFlakes;
    autoOptimiseStore = true;
    gc = {
      options = "--delete-older-than 15d";
    };
    extraOptions = ''
      min-free = ${toString 1 * 1024*1024*1024}
      max-free = ${toString 1 * 1024*1024*1024}
      experimental-features = nix-command flakes
    '';
  };
  boot.cleanTmpDir = true;
  networking.hostName = "cloudhead";
  i18n.defaultLocale = "pt_BR.UTF-8";
  time.timeZone = "America/Sao_Paulo";
  environment.systemPackages = with pkgs; [
    dotenv
    rclone
    restic
    neovim
  ];
  environment.variables.EDITOR = "nvim";
  services.openssh = {
    enable = true;
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80 443
      59356 
      6969 6970 6971 6972 6973 6974 6975 6976 6977 6978 6979 6980
    ];
    allowedUDPPorts = [
      22
      80 443
      59356 
      6969 6970 6971 6972 6973 6974 6975 6976 6977 6978 6979 6980
    ];
  };
  services.zerotierone = {
    enable = true;
    port = 6969;
    joinNetworks = [
      "e5cd7a9e1c857f07"
    ];
  };
  users.users = {
    ${adm} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
      ];
      description = "Ademir";
    };
  };
  virtualisation.docker.enable = true;
  services.irqbalance.enable = true;

  cachix.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_5_10;
  system.stateVersion = "20.03";
}
