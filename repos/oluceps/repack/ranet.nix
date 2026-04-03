{
  reIf,
  config,
  lib,
  pkgs,
  inputs',
  inputs,
  ...
}:

let
  inherit (config.networking) hostName;
  thisNode = lib.data.node.${hostName};
  # determine the address family based on the string content
  getFamily = ip: if lib.strings.hasInfix ":" ip then "ip6" else "ip4";

  updownScript = pkgs.writeShellScript "ranet-updown" ''
    exec >> /tmp/ranet-updown.log 2>&1
    echo "[$(date)] Triggered: VERB=''${PLUTO_VERB}, IF_ID=''${PLUTO_IF_ID_IN}"

    # use if_id to guarantee unique interface names for multiple tunnels
    ifname="xfrm-''${PLUTO_IF_ID_IN}"

    case "''${PLUTO_VERB}" in
        up-client-v6)
            echo "creating XFRM interface $ifname..."
            ${pkgs.iproute2}/bin/ip link add "''${ifname}" type xfrm if_id "''${PLUTO_IF_ID_IN}" || true
            ${pkgs.iproute2}/bin/ip link set "''${ifname}" multicast on || true
            ${pkgs.iproute2}/bin/ip link set "''${ifname}" mtu 1500 || true
            ${pkgs.iproute2}/bin/ip link set "''${ifname}" up || true
            echo "interface $ifname is UP."
            ;;
        down-client-v6)
            echo "deleting XFRM interface $ifname..."
            ${pkgs.iproute2}/bin/ip link del "''${ifname}" || true
            ;;
        *)
            echo "ignored VERB: ''${PLUTO_VERB}"
            ;;
    esac
  '';
  configFile = pkgs.writeText "config.json" (
    builtins.toJSON {
      organization = "garden";
      common_name = config.networking.hostName;
      endpoints =
        if thisNode.nat then
          [
            {
              serial_number = "0";
              address_family = "ip4";
              port = 26232;
              updown = "${updownScript}";
            }
            {
              serial_number = "1";
              address_family = "ip6";
              port = 26232;
              updown = "${updownScript}";
            }
          ]
        else
          lib.imap0 (index: ip: {
            address_family = getFamily ip;
            port = 26232;
            serial_number = toString index;
            address = ip;
            updown = "${updownScript}";
          }) thisNode.addrs;
      experimental = {
        iptfs = false;
      };
    }

  );
  registryFile = pkgs.writeText "registry.json" (
    builtins.toJSON [
      {
        nodes =
          (map (n: {
            common_name = n;
            endpoints =
              lib.imap0
                (index: ipv: {
                  address_family = ipv;
                  port = 26232;
                  serial_number = toString index;
                })
                [
                  "ip4"
                  "ip6"
                ];
          }) (lib.attrNames (lib.filterAttrs (_: v: v.nat) lib.data.node)))
          ++ (map (
            i:
            let
              inherit (i.value) addrs;
            in
            {
              common_name = i.name;
              endpoints = lib.imap0 (index: ip: {
                address_family = getFamily ip;
                port = 26232;
                serial_number = toString index;
                address = ip;
              }) addrs;
            }
          ) (lib.attrsToList (lib.filterAttrs (_: v: !v.nat) lib.data.node)));
        organization = "garden";
        public_key = "-----BEGIN PUBLIC KEY-----\nMCowBQYDK2VwAyEAfI8xB8uoVFOUTzCunsZ6vbYYlx6jzGRI2rE5BU3DJF0=\n-----END PUBLIC KEY-----";
      }
    ]
  );
in
reIf {
  # strongswan provides the vici socket required by ranet

  environment.systemPackages = [
    config.services.strongswan-swanctl.package
    inputs'.ranet.packages.default
  ];

  networking = {
    firewall = {
      allowedTCPPorts = [
        26232
      ];
      allowedUDPPorts = [
        26232
      ];
    };
  };
  # use sops to handle the private key securely
  vaultix.secrets."garden_key" = { };

  # systemd service for reconciling ranet state
  systemd.services.garden =
    let
      cmd = "${inputs'.ranet.packages.default}/bin/ranet --config ${configFile} --registry $\{STATE_DIRECTORY}/registry.json --key ${config.vaultix.secrets.garden_key.path}";
    in
    {
      description = "ranet full mesh ipsec daemon";
      wants = [
        "network-online.target"
        "strongswan-swanctl.service"
      ];
      after = [
        "network-online.target"
        "strongswan-swanctl.service"
      ];
      wantedBy = [ "multi-user.target" ];
      path = [
        inputs'.ranet.packages.default
        pkgs.iproute2
      ];
      bindsTo = [ "strongswan-swanctl.service" ];
      reload = "${cmd} up";
      preStart = "cp ${registryFile} /var/lib/garden/registry.json";

      serviceConfig = {
        StateDirectory = "garden";

        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${cmd} up";
        ExecStop = "${cmd} down";
      };
    };
  services.strongswan-swanctl = {
    enable = true;
    strongswan.extraConfig = ''
      charon {
        ikesa_table_size = 32
        ikesa_table_segments = 4
        reuse_ikesa = no
        interfaces_use = ${
          lib.strings.concatStringsSep "," [
            "eno1"
            "eth0"
          ]
        }
        port = 0
        port_nat_t = ${toString 26232}
        retransmit_timeout = 30
        retransmit_base = 1
        plugins {
          socket-default {
            set_source = yes
            set_sourceif = yes
          }
          dhcp {
            load = no
          }
        }
      }
      charon-systemd {
        journal {
          default = -1
        }
      }
    '';
  };

}
