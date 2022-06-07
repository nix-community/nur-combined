{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.kampka.services.dns-cache;

  dhcpHostOpts = { name, config, ... }: {
    options = {
      hardwareAddress = mkOption {
        type = types.str;
        description = "The hardware address (MAC) of the machine requesting a lease.";
      };

      name = mkOption {
        type = types.str;
        description = "The hostname to assign to the given hardware address";
      };

      ipAddress = mkOption {
        type = types.str;
        description = "The IP address leased to the given hardware address";
      };

      leaseTime = mkOption {
        type = types.str;
        default = "infinite";
        description = "The lease time is in seconds, or minutes (eg 45m) or hours (eg 1h) or 'infinite'. The minimum lease time is two minutes.";
      };

      staticRecord = mkOption {
        type = types.bool;
        default = true;
        description = "If set, a static A record will be added for the host";
      };
    };
  };

  dhcpRangeOpts = { name, config, ... }: {
    options = {
      interface = mkOption {
        type = types.str;
        description = "The name of the network interface this lease range is associated with.";
      };

      startAddr = mkOption {
        type = types.str;
        description = "The start address of the dhcp range";
      };

      endAddr = mkOption {
        type = types.str;
        description = "The end address of the dhcp range";
      };

      leaseTime = mkOption {
        type = types.str;
        default = "1h";
        description = "The lease time is in seconds, or minutes (eg 45m) or hours (eg 1h) or 'infinite'. If not given, the default lease time is one hour. The minimum lease time is two minutes.";
      };
    };
  };

  domainOpt = { config, ... }: {
    options = {
      name = mkOption {
        type = types.str;
      };
      network = mkOption {
        type = types.nullOr types.str;
        example = "10.0.0.0/8";
        default = null;
      };
      local = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  dhcpOpts = { name, config, ... }: {
    options = {
      domain = mkOption {
        type = types.submodule domainOpt;
      };
      range = mkOption {
        type = types.listOf (types.submodule dhcpRangeOpts);
        default = [ ];
        description = "Specify per host parameters for the DHCP server. This allows a machine with a particular hardware address to be always allocated the same hostname, IP address and lease time.";
      };
      host = mkOption {
        type = types.listOf (types.submodule dhcpHostOpts);
        default = [ ];
        description = "Enable the DHCP server. Addresses will be given out from the range <start-addr> to <end-addr> and from statically defined addresses given in dhcpHosts options.";
      };
    };
  };

in
{
  options.kampka.services.dns-cache = {
    enable = mkEnableOption "dns cache service with dns-over-tls";

    stubbySetting = mkOption
      {
        description = "List of upstream dns servers";
        type = types.attrsOf settingsFormat.type;
        default = pkgs.stubby.passthru.settingsExample // {
          upstream_recursive_servers = [
            # Nameserver run by digitalcourage
            {
              address_data = "46.182.19.48";
              tls_auth_name = "dns2.digitalcourage.de";
              tls_pubkey_pinset = {
                value = "v7rm6OtQQD3x/wbsdHDZjiDg+utMZvnoX3jq3Vi8tGU=";
                digest = "sha256";
              };
            }
            {
              address_data = "2a02:2970:1002::18";
              tls_auth_name = "dns2.digitalcourage.de";
              tls_pubkey_pinset = {
                value = "v7rm6OtQQD3x/wbsdHDZjiDg+utMZvnoX3jq3Vi8tGU=";
                digest = "sha256";
              };
            }

            # Nameserver run by dismail.de
            {
              address_data = "80.241.218.68";
              tls_auth_name = "fdns1.dismail.de";
              tls_pubkey_pinset = {
                value = "MMi3E2HZr5A5GL+badqe3tzEPCB00+OmApZqJakbqUU=";
                digest = "sha256";
              };
            }
            {
              address_data = "2a02:c205:3001:4558::1";
              tls_auth_name = "fdns1.dismail.de";
              tls_pubkey_pinset = {
                value = "MMi3E2HZr5A5GL+badqe3tzEPCB00+OmApZqJakbqUU=";
                digest = "sha256";
              };
            }

            # Nameserver run by dismail.de
            {
              address_data = "159.69.114.157";
              tls_auth_name = "fdns2.dismail.de";
              tls_pubkey_pinset = {
                value = "yJYDim2Wb6tbxUB3yA5ElU/FsRZZhyMXye8sXhKEd1w=";
                digest = "sha256";
              };
            }
            {
              address_data = "2a01:4f8:c17:739a::2";
              tls_auth_name = "fdns2.dismail.de";
              tls_pubkey_pinset = {
                value = "yJYDim2Wb6tbxUB3yA5ElU/FsRZZhyMXye8sXhKEd1w=";
                digest = "sha256";
              };
            }
          ];
        };
      }

      dnsmasq = mkOption {
    default = { };
    type = types.submodule {
      options = {
        noNegCache = mkOption {
          type = types.bool;
          default = true;
          description = "Disable negative result caching";
        };

        allServers = mkOption {
          type = types.bool;
          default = true;
          description = "Enables querying all configured servers, using the first positive result";
        };

        bogusPriv = mkOption {
          type = types.bool;
          default = false;
          description = ''Bogus private reverse lookups. All reverse lookups for private IP ranges (ie 192.168.x.x, etc) which are not found in /etc/hosts or the DHCP leases file are answered with "no such domain" rather than being forwarded upstream. The set of prefixes affected is the list given in RFC6303, for IPv4 and IPv6.'';
        };

        interfaces = mkOption {
          type = types.listOf types.str;
          default = [ "lo" ];
          description = "List of network interfaces to bind to.";
        };

        cache-size = mkOption {
          type = types.int;
          default = 1500;
          description = "Amount of DNS resolves to cache";
        };

        dhcp = mkOption {
          type = types.listOf (types.submodule dhcpOpts);
          default = [ ];
          description = "DNSMasq dhcp options";
        };

        logQueries = mkOption {
          type = types.bool;
          default = false;
          description = "If enabled, DNSMasq logs all DNS queries";
        };

        validateDnsSec = mkOption {
          type = types.bool;
          default = true;
          description = "If enabled, causes DNSMasq to validate DNSSEC records";
        };

        extraConfig = mkOption {
          type = types.str;
          default = "";
        };
      };
    };
  };
};

config = mkIf cfg.enable {

networking.nameservers = [ "127.0.0.1" ];

services.stubby = {
enable = true;
debugLogging = false;
settings = (cfg.stubbySetting // { resolution_type = "GETDNS_RESOLUTION_STUB"; });
};

services.dnsmasq = {
enable = true;
servers = [ "127.0.0.1#5353" ];
resolveLocalQueries = false;
extraConfig = ''
                  ${optionalString (cfg.dnsmasq.validateDnsSec) "
        dnssec
        dnssec-check-unsigned
        conf-file=${pkgs.dnsmasq}/share/dnsmasq/trust-anchors.conf
        "}
                  ${optionalString (cfg.dnsmasq.noNegCache) "
        # Disable negative caching. Negative caching allows dnsmasq to remember 'no such domain' answers from upstream nameservers and answer identical queries without forwarding them again.
        no-negcache
        "}
                  ${optionalString (cfg.dnsmasq.allServers) "
        # Query all configured server for a successful dns resolve
        all-servers
        "}

                ${optionalString (cfg.dnsmasq.bogusPriv) ''
                # Prevent queries for local networks from being sent upstream
                bogus-priv
              ''}

                ${concatStringsSep "\n" (map (interface: "interface=${interface}") cfg.dnsmasq.interfaces)}

                ${optionalString (cfg.dnsmasq.dhcp != [ ]) "
        no-dhcp-interface=lo
        dhcp-ttl=180
        "}

                ${concatStringsSep "\n" (
map
(
dhcp: ''

        domain=${dhcp.domain.name}${optionalString (dhcp.domain.network != "") ",${dhcp.domain.network}${optionalString (dhcp.domain.local) ",local" }"}

        ${concatStringsSep "\n" (
map
(
range: "dhcp-range=set:${range.interface},${range.startAddr},${range.endAddr},${range.leaseTime}
        "
)
dhcp.range
)}

        ${concatStringsSep "\n" (
map
(
host: ''
                        dhcp-host=${host.hardwareAddress},${host.name},${host.ipAddress},${host.leaseTime},set:${host.name}
                        ${optionalString (host.staticRecord) "host-record=${host.name},${host.name}.${dhcp.domain.name},${host.ipAddress},120" }
                      ''
)
dhcp.host
)}

        ''
)
cfg.dnsmasq.dhcp
)}

                ${optionalString (cfg.dnsmasq.logQueries) "
        log-queries
        "}

        cache-size=${toString cfg.dnsmasq.cache-size}

                ${cfg.dnsmasq.extraConfig}
      '';
};

# Likely redundant in this case
services.nscd.enable = mkDefault false;
};
}
