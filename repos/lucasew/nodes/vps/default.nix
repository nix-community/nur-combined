{pkgs, lib, global, ...}:
let
  inherit (flake) inputs;
  inherit (pkgs) dotenv;
  inherit (global) username rootPath;
  inherit (lib) mkOverride;
in {
  imports = [
    ../common/default.nix
    "${inputs.nixpkgs}/nixos/modules/virtualisation/google-compute-image.nix"
    "${inputs.impermanence}/nixos.nix"
    ../../modules/cachix/system.nix
    ./modules
  ];

  vps = {
    # alibot.enable = true;
    pgbackup.enable = true;
  };
  
  environment.persistence."/persist" = {
    files = [
      "/etc/machine-id"
    ];
    directories = [
      "${toString rootPath}/secrets"
      "/backups"
    ];
  };

  swapDevices = [
    { device = "/swapfile"; }
  ];

  nixpkgs.config.allowUnfree = true;
  networking.hostName = "cloudhead";
  environment.systemPackages = [
    dotenv
  ];
  networking.firewall = {
    enable = true;
    trustedInterfaces = [
      "ztppi77yi3" # zerotier
    ];
    allowedTCPPortRanges = [
      {from = 6969; to = 6980; }
    ];
    allowedUDPPortRanges = [
      {from = 6969; to = 6980; }
    ];
    allowedTCPPorts = [
      # 22
      # 80 443
      # 59356 
    ];
  };
  users.users = {
    ${username} = {
      description = "Ademir";
    };
  };
  virtualisation.docker.enable = true;
  services = {
    irqbalance.enable = true;
    postgresql = {
      enable = true;
      enableTCPIP = true;
      authentication = mkOverride 10 ''
        local all all trust
        host all all 192.168.69.0/24 trust
      '';
    };
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
