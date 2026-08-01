{
  config,
  lib,
  pkgs,
  flakeRoot,
  nixosModules,
  ...
}:

let
  secrets = flakeRoot + /secrets;
  hostUtils = import (flakeRoot + /lib/hostUtils.nix) { inherit lib; };
  userKeys = hostUtils.collectSshKeys { inherit flakeRoot; };
in

{
  imports = [
    secrets
  ]
  ++ (with nixosModules; [
    programs.nix
  ]);

  users.users = {
    iamanaws.openssh.authorizedKeys.keys = [ userKeys.archimedes.iamanaws ];
  };

  environment.systemPackages = with pkgs; [
    wpa_supplicant
    vim
  ];

  networking = {
    interfaces."wlan0".useDHCP = true;
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];

      # Networks defined in aux imperitive networks (/etc/wpa_supplicant.conf)
      userControlled.enable = true;
      allowAuxiliaryImperativeNetworks = true;
    };
    # override core defaults
    networkmanager.enable = lib.mkForce false;
    # Open firewall ports for DNS
    firewall.allowedUDPPorts = [
      53
      67
      68
    ];
  };

  # Link /etc/wpa_supplicant.conf -> secret config
  environment.etc."wpa_supplicant.conf" = {
    source = config.sops.secrets.wireless.path;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services = {
    getty.autologinUser = lib.mkForce "iamanaws";
    openssh.enable = true;
    timesyncd.enable = true;
  };

  zramSwap.enable = true;

  # Some packages (ahci fail... this bypasses that) https://discourse.nixos.org/t/does-pkgs-linuxpackages-rpi3-build-all-required-kernel-modules/42509
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

}
