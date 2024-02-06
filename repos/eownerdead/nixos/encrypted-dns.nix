{ lib, pkgs, config, ... }:
with lib; {
  options.eownerdead.encryptedDns = mkEnableOption (mdDoc ''
    Resolve domain name with encrypted DNS.

    See the (wiki)[https://nixos.wiki/wiki/Encrypted_DNS].
  '');

  config = mkIf config.eownerdead.encryptedDns {
    networking = {
      nameservers = mkDefault [ "127.0.0.1" "::1" ];
      networkmanager.dns = mkDefault "none";
    };

    services.dnscrypt-proxy2 = {
      enable = mkDefault true;
      settings = mkDefault {
        ipv6_servers = true;
        require_dnssec = true;
        http3 = true;
      };
    };
  };
}

