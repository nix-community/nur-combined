{
  pkgs,
  lib,
  global,
  self,
  config,
  ...
}:
let
  inherit (pkgs) dotenv;
  inherit (global) username rootPath;
  inherit (lib) mkOverride;
in
{
  imports = [
    ../common/default.nix
    "${self.inputs.nixpkgs}/nixos/modules/virtualisation/google-compute-image.nix"

    "${self.inputs.impermanence}/nixos.nix"

    ./modules
    ./nvidia.nix
  ];

  nix.settings.min-free = 64 * 1024 * 1024; # trigger do gc mais baixo

  services.openssh.settings.X11Forwarding = true;
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
    files = [ "/etc/machine-id" ];
    directories = [ "/backups" ];
    users.${username}.directories = [
      "WORKSPACE"
      "TMP2"
    ];
  };

  swapDevices = [ { device = "/persist/swapfile"; } ];

  nixpkgs.config.allowUnfree = true;
  networking.hostName = "ravenrock";
  environment.systemPackages = with pkgs; [
    dotenv
    htop
    neofetch
  ];
  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      {
        from = 6969;
        to = 6980;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 6969;
        to = 6980;
      }
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
