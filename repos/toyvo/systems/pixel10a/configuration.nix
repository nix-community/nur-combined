{
  lib,
  inputs,
  system,
  homelab,
  stablePkgs,
  unstablePkgs,
  config,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixos-avf.nixosModules.avf
    inputs.nixos-unstable.nixosModules.notDetected
    inputs.nur.modules.nixos.default
    inputs.sops-nix.nixosModules.sops
  ];
  home-manager = {
    extraSpecialArgs = {
      inherit
        inputs
        system
        homelab
        stablePkgs
        unstablePkgs
        ;
    };
    sharedModules = [ ./home.nix ];
  };
  avf.defaultUser = "toyvo";
  networking = {
    hostName = "pixel10a";
    wireguard.interfaces.wg0 = {
      ips = [ "10.100.0.3/24" ];
      privateKeyFile = config.sops.secrets.wireguard-pixel10a-private-key.path;
      peers = [
        {
          publicKey = "9EZ8ZiCF34RiMr06QiKBIYGckS9DFUBeX85boFhz2yo=";
          allowedIPs = [
            "10.1.0.0/24"
            "10.100.0.0/24"
            "10.200.0.0/24"
          ];
          persistentKeepalive = 25;
          endpoint = "toyvo.dev:51820";
        }
      ];
    };
  };
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    resolved.settings.Resolve.DNSSEC = "false";
  };
  sops.secrets.wireguard-pixel10a-private-key = { };
  system.stateVersion = "26.05";
}
