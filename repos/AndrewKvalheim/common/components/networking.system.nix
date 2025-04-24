{ config, lib, ... }:

let
  inherit (config) host;
  inherit (lib) mkOption;
  inherit (lib.types) str;

  identity = import ../resources/identity.nix;
in
{
  options.host.name = mkOption { type = str; };

  config = {
    # Identity
    networking.hostName = host.name;
    networking.domain = "home.arpa";
    networking.networkmanager.wifi.macAddress = "stable" /* hashed */;

    # DNS
    services.resolved.dnssec = "false";
    services.resolved.extraConfig = ''
      StaleRetentionSec=3600
    '';

    # Permissions
    users.users.${identity.username}.extraGroups = [ "networkmanager" ];

    # Work around NixOS/nixpkgs#180175
    # TODO: Is this related to WireGuard? Or maybe virtualization?
    systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
    systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
  };
}
