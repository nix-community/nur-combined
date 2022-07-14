{pkgs, lib, global, self, config, ...}:
let
  inherit (self) inputs;
  inherit (pkgs) dotenv;
  inherit (global) username rootPath;
  inherit (lib) mkOverride;
  # our_cudatoolkit = pkgs.cudaPackages_10.cudatoolkit;
in {
  imports = [
    ../common/default.nix
    "${inputs.nixpkgs}/nixos/modules/virtualisation/google-compute-image.nix"
    "${inputs.impermanence}/nixos.nix"
    ../../modules/cachix/system.nix
    ./modules
    ./nvidia.nix
  ];

  nix.settings.min-free = 64 * 1024 * 1024; # trigger do gc mais baixo

  services.openssh.forwardX11 = true;
  fileSystems = {
    # "/persist" = {
    #   neededForBoot = true;
    #   device = "/dev/sdb1";
    #   fsType = "ext4";
    # };
  };

  vps = {
    domain = "ztvps.biglucas.tk";
    # alibot.enable = true;
    # pgbackup.enable = true;
  };
  
  environment.persistence."/persist" = {
    hideMounts = true;
    files = [
      "/etc/machine-id"
    ];
    directories = [
      {directory = "${toString rootPath}"; user = username; mode = "0755";}
      "/backups"
      "/srv/php-utils"
    ];
    users.${username}.directories = [
      "WORKSPACE"
      "TMP2"
    ];
  };

  swapDevices = [
    { device = "/persist/swapfile"; }
  ];

  nixpkgs.config.allowUnfree = true;
  networking.hostName = "cloudhead";
  environment.systemPackages = with pkgs; [
    dotenv
    htop
    neofetch
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
  virtualisation.docker = {
    enable = true;
  };
  services = {
    # dnsmasq = {
    #   enable = true;
    #   resolveLocalQueries = true;
    # };
    irqbalance.enable = true;
    # php-utils.enable = true;
    # vaultwarden.enable = true;
    # postgresql = {
    #   enable = true;
    #   enableTCPIP = true;
    #   authentication = mkOverride 10 ''
    #     local all all trust
    #     host all all 192.168.69.0/24 trust
    #   '';
    # };
    # randomtube = { # TODO: Bump git commit
    #   enable = false;
    #   extraParameters = "-ms 120";
    #   secretsDotenv = "${rootPath}/secrets/randomtube.env";
    # };
  };

  cachix.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_5_4;
  # services.nginx = {
  #   enable = true;
  #   enableReload = true;
  # };
  system.stateVersion = "20.03";
}
