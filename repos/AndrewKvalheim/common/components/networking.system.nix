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
    services.resolved.extraConfig = ''
      DNSSEC=no
      StaleRetentionSec=3600
    '';

    # Workaround for `avahi-daemon[1234]: Failed to read /etc/avahi/services.`
    # Upstream: https://github.com/lathiat/avahi/blob/v0.8/avahi-daemon/static-services.c#L917-L919
    system.activationScripts.etcAvahiServices = "mkdir -p /etc/avahi/services";

    # Permissions
    users.users.${identity.username}.extraGroups = [ "networkmanager" ];
  };
}
