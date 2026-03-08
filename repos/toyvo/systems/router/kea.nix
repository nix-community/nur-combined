{ homelab, lib, ... }:
let
  reserved = 64;
in
{
  services.kea = {
    dhcp4 = {
      enable = true;
      settings = {
        interfaces-config = {
          interfaces = [
            "br0"
            "br0.20"
            "br0.30"
          ];
          dhcp-socket-type = "raw";
        };
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };
        authoritative = true;
        renew-timer = 3600 * 5;
        rebind-timer = 3600 * 8;
        valid-lifetime = 3600 * 9;
        subnet4 = [
          {
            id = 1;
            pools = [
              {
                pool = "10.1.0.${toString reserved} - 10.1.0.254";
              }
            ];
            subnet = "10.1.0.0/24";
            option-data = [
              {
                name = "routers";
                data = "10.1.0.1";
              }
            ];
            reservations =
              lib.mapAttrsToList
                (
                  hostname:
                  { ip, mac, ... }:
                  {
                    inherit hostname;
                    ip-address = ip;
                    hw-address = mac;
                  }
                )
                (
                  lib.filterAttrs (
                    hostname:
                    {
                      ip ? "",
                      ...
                    }:
                    let
                      inSubnet = lib.hasPrefix "10.1.0." ip;
                      hostAddress = lib.strings.toInt (lib.last (lib.splitString "." ip));
                    in
                    inSubnet && hostAddress > 1 && hostAddress < reserved
                  ) homelab
                );
          }
          {
            id = 20;
            pools = [
              {
                pool = "10.1.20.${toString reserved} - 10.1.20.254";
              }
            ];
            subnet = "10.1.20.0/24";
            option-data = [
              {
                name = "routers";
                data = "10.1.20.1";
              }
            ];
          }
          {
            id = 30;
            pools = [
              {
                pool = "10.1.30.${toString reserved} - 10.1.30.254";
              }
            ];
            subnet = "10.1.30.0/24";
            option-data = [
              {
                name = "routers";
                data = "10.1.30.1";
              }
            ];
          }
        ];
        option-data = [
          {
            name = "domain-name-servers";
            data = "10.1.0.1";
          }
          {
            name = "domain-search";
            data = "diekvoss.internal, diekvoss.net, diekvoss.com";
          }
        ];
        loggers = [
          {
            name = "kea-dhcp4";
            output_options = [
              {
                output = "/var/log/kea/kea-dhcp4.log";
                maxver = 10;
              }
            ];
            severity = "INFO";
          }
        ];
      };
    };
    dhcp6 = {
      enable = true;
      settings = {
        interfaces-config.interfaces = [
          "br0"
          "br0.20"
          "br0.30"
        ];
        lease-database = {
          name = "/var/lib/kea/dhcp6.leases";
          persist = true;
          type = "memfile";
        };
        renew-timer = 3600 * 5;
        rebind-timer = 3600 * 8;
        valid-lifetime = 3600 * 9;
        preferred-lifetime = 3600 * 7;
        subnet6 = [
          {
            id = 1;
            pools = [
              {
                pool = "fdcd:2022:1118::${lib.toHexString reserved} - fdcd:2022:1118::ffff";
              }
            ];
            subnet = "fdcd:2022:1118::/64";
            reservations =
              lib.mapAttrsToList
                (
                  hostname:
                  { ip, mac, ... }:
                  let
                    hostAddress = lib.strings.toInt (lib.last (lib.splitString "." ip));
                  in
                  {
                    inherit hostname;
                    ip-addresses = [ "fdcd:2022:1118::${lib.toHexString hostAddress}" ];
                    hw-address = mac;
                  }
                )
                (
                  lib.filterAttrs (
                    hostname:
                    {
                      ip ? "",
                      ...
                    }:
                    let
                      inSubnet = lib.hasPrefix "10.1.0." ip;
                      hostAddress = lib.strings.toInt (lib.last (lib.splitString "." ip));
                    in
                    inSubnet && hostAddress > 1 && hostAddress < reserved
                  ) homelab
                );
          }
          {
            id = 20;
            pools = [
              {
                pool = "fdcd:2022:1118:20::${lib.toHexString reserved} - fdcd:2022:1118:20::ffff";
              }
            ];
            subnet = "fdcd:2022:1118:20::/64";
          }
          {
            id = 30;
            pools = [
              {
                pool = "fdcd:2022:1118:30::${lib.toHexString reserved} - fdcd:2022:1118:30::ffff";
              }
            ];
            subnet = "fdcd:2022:1118:30::/64";
          }
        ];
        option-data = [
          {
            name = "dns-servers";
            data = "fdcd:2022:1118::1";
          }
          {
            name = "domain-search";
            data = "diekvoss.internal, diekvoss.net, diekvoss.com";
          }
        ];
        loggers = [
          {
            name = "kea-dhcp6";
            output_options = [
              {
                output = "/var/log/kea/kea-dhcp6.log";
                maxver = 10;
              }
            ];
            severity = "INFO";
          }
        ];
      };
    };
  };
}
