{pkgs, ...}:
with builtins;
with import ../../globalConfig.nix;
{
  imports = [
    ../common/default.nix
    "${flake.inputs.nixpkgs}/nixos/modules/virtualisation/google-compute-image.nix"
    "${flake.inputs.impermanence}/nixos.nix"
    ../../modules/cachix/system.nix
    ./modules/alibot.nix
  ];
  
  environment.persistence."/persist" = {
    files = [
      "/etc/machine-id"
    ];
    directories = [
      "${toString rootPath}/secrets"
    ];
  };

  swapDevices = [
    { device = "/swapfile"; }
  ];

  nixpkgs.config.allowUnfree = true;
  networking.hostName = "cloudhead";
  environment.systemPackages = with pkgs; [
    dotenv
  ];
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
  users.users = {
    ${username} = {
      description = "Ademir";
    };
  };
  virtualisation.docker.enable = true;
  services = {
    alibot.enable = true;
    zerotierone.enable = true;
    irqbalance.enable = true;
    randomtube = { # TODO: Bump git commit
      enable = false;
      extraParameters = "-ms 120";
      secretsDotenv = "${rootPath}/secrets/randomtube.env";
    };
    cloudflared.enable = true;
  };

  cachix.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_5_4;
  system.stateVersion = "20.03";
}
