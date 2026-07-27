{ homelab, lib, ... }:
let
  reserved = 64;
  ipv4NetworkPrefix = "10.1";
  ipv6NetworkPrefix = "fdcd:2022:1118";
  homeVlanId = "10";
  guestVlanId = "20";
  iotVlanId = "30";
in
{
  services.kea = {
    dhcp4 = {
      enable = true;
      settings = {
        interfaces-config = {
          interfaces = [
            "br0"
            "br0.${homeVlanId}"
            "br0.${guestVlanId}"
            "br0.${iotVlanId}"
          ];
          dhcp-socket-type = "raw";
        };
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };
        control-socket = {
          socket-type = "unix";
          socket-name = "/run/kea/kea-dhcp4.socket";
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
                pool = "${ipv4NetworkPrefix}.0.${toString reserved} - ${ipv4NetworkPrefix}.0.254";
              }
            ];
            subnet = "${ipv4NetworkPrefix}.0.0/24";
            option-data = [
              {
                name = "routers";
                data = "${ipv4NetworkPrefix}.0.1";
              }
              {
                name = "domain-name-servers";
                data = "${ipv4NetworkPrefix}.0.1";
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
                      inSubnet = lib.hasPrefix "${ipv4NetworkPrefix}.0." ip;
                      hostAddress = lib.strings.toInt (lib.last (lib.splitString "." ip));
                    in
                    inSubnet && hostAddress > 1 && hostAddress < reserved
                  ) homelab
                );
          }
          {
            id = lib.strings.toInt homeVlanId;
            pools = [
              {
                pool = "${ipv4NetworkPrefix}.${homeVlanId}.${toString reserved} - ${ipv4NetworkPrefix}.${homeVlanId}.254";
              }
            ];
            subnet = "${ipv4NetworkPrefix}.${homeVlanId}.0/24";
            option-data = [
              {
                name = "routers";
                data = "${ipv4NetworkPrefix}.${homeVlanId}.1";
              }
              {
                name = "domain-name-servers";
                data = "${ipv4NetworkPrefix}.${homeVlanId}.1";
              }
            ];
          }
          {
            id = lib.strings.toInt guestVlanId;
            pools = [
              {
                pool = "${ipv4NetworkPrefix}.${guestVlanId}.${toString reserved} - ${ipv4NetworkPrefix}.${guestVlanId}.254";
              }
            ];
            subnet = "${ipv4NetworkPrefix}.${guestVlanId}.0/24";
            option-data = [
              {
                name = "routers";
                data = "${ipv4NetworkPrefix}.${guestVlanId}.1";
              }
              {
                name = "domain-name-servers";
                data = "${ipv4NetworkPrefix}.${guestVlanId}.1";
              }
            ];
          }
          {
            id = lib.strings.toInt iotVlanId;
            pools = [
              {
                pool = "${ipv4NetworkPrefix}.${iotVlanId}.${toString reserved} - ${ipv4NetworkPrefix}.${iotVlanId}.254";
              }
            ];
            subnet = "${ipv4NetworkPrefix}.${iotVlanId}.0/24";
            option-data = [
              {
                name = "routers";
                data = "${ipv4NetworkPrefix}.${iotVlanId}.1";
              }
              {
                name = "domain-name-servers";
                data = "${ipv4NetworkPrefix}.${iotVlanId}.1";
              }
            ];
          }
        ];
        option-data = [
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
          "br0.${homeVlanId}"
          "br0.${guestVlanId}"
          "br0.${iotVlanId}"
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
                pool = "${ipv6NetworkPrefix}::${lib.toHexString reserved} - ${ipv6NetworkPrefix}::ffff";
              }
            ];
            subnet = "${ipv6NetworkPrefix}::/64";
            option-data = [
              {
                name = "dns-servers";
                data = "${ipv6NetworkPrefix}::1";
              }
            ];
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
                    ip-addresses = [ "${ipv6NetworkPrefix}::${lib.toHexString hostAddress}" ];
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
                      inSubnet = lib.hasPrefix "${ipv4NetworkPrefix}.0." ip;
                      hostAddress = lib.strings.toInt (lib.last (lib.splitString "." ip));
                    in
                    inSubnet && hostAddress > 1 && hostAddress < reserved
                  ) homelab
                );
          }
          {
            id = lib.strings.toInt homeVlanId;
            pools = [
              {
                pool = "${ipv6NetworkPrefix}:${homeVlanId}::${lib.toHexString reserved} - ${ipv6NetworkPrefix}:${homeVlanId}::ffff";
              }
            ];
            subnet = "${ipv6NetworkPrefix}:${homeVlanId}::/64";
            option-data = [
              {
                name = "dns-servers";
                data = "${ipv6NetworkPrefix}:${homeVlanId}::1";
              }
            ];
          }
          {
            id = lib.strings.toInt guestVlanId;
            pools = [
              {
                pool = "${ipv6NetworkPrefix}:${guestVlanId}::${lib.toHexString reserved} - ${ipv6NetworkPrefix}:${guestVlanId}::ffff";
              }
            ];
            subnet = "${ipv6NetworkPrefix}:${guestVlanId}::/64";
            option-data = [
              {
                name = "dns-servers";
                data = "${ipv6NetworkPrefix}:${guestVlanId}::1";
              }
            ];
          }
          {
            id = lib.strings.toInt iotVlanId;
            pools = [
              {
                pool = "${ipv6NetworkPrefix}:${iotVlanId}::${lib.toHexString reserved} - ${ipv6NetworkPrefix}:${iotVlanId}::ffff";
              }
            ];
            subnet = "${ipv6NetworkPrefix}:${iotVlanId}::/64";
            option-data = [
              {
                name = "dns-servers";
                data = "${ipv6NetworkPrefix}:${iotVlanId}::1";
              }
            ];
          }
        ];
        option-data = [
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
