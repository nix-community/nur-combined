{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
{
  options.eownerdead.encryptedDns = mkEnableOption (mdDoc ''
    Resolve domain name with encrypted DNS.

    See the (wiki)[https://nixos.wiki/wiki/Encrypted_DNS].
  '');

  config = mkIf config.eownerdead.encryptedDns {
    networking = {
      nameservers = mkDefault [
        "127.0.0.1"
      ];
      networkmanager.dns = mkDefault "none";
    };

    services = {
      resolved.enable = mkForce false;
      dnscrypt-proxy = {
        enable = mkForce true;
        settings = mkDefault {
          server_names = [ "mullvad-base-doh" ];
          http3 = true;
          dnscrypt_servers = false;
          ipv6_servers = true;
        };
      };
    };
  };
}
