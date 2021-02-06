{pkgs, ...}:
with import ../../globalConfig.nix;
{
  imports = [
    ../bootstrap/default.nix
     "${flake.inputs.nixpkgs}/nixos/modules/virtualisation/google-compute-image.nix"
    ../../modules/cachix/system.nix
    ../../modules/randomtube/system.nix
    ../../modules/vercel-ddns/system.nix
  ];

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
    zerotierone.enable = true;
    irqbalance.enable = true;
    randomtube = {
      enable = false;
      extraParameters = "-ms 120";
      secretsDotenv = "${rootPath}/secrets/randomtube.env";
    };
    vercel-ddns = {
      enable = true;
      vercelTokenFile = "${rootPath}/secrets/vercel.env";
      domain = "biglucas.tk";
      name = "vps";
    };
  };

  cachix.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_5_4;
  system.stateVersion = "20.03";
}
