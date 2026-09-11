{ ... }:

{
  # Configure network connections interactively with nmcli or nmtui.
  # networking.networkmanager.enable = true;
  networking.useDHCP = false;
  systemd.network.enable = true;
  systemd.network = {
    netdevs = {
      "10-bond0" = {
        netdevConfig = {
          Kind = "bond";
          Name = "bond0";
          MACAddress = "00:48:54:20:b7:b2";
        };
        bondConfig = {
          # Mode = "active-backup";
          # Mode = "802.3ad";
          Mode = "balance-xor";
          TransmitHashPolicy = "layer3+4";
        };
      };
      "20-vm0" = {
        netdevConfig = {
          Kind = "macvtap";
          Name = "vm0";
          MACAddress = "00:48:54:20:b7:ff";
        };
      };
    };
    networks = {
      "30-r8169" = {
        matchConfig.Driver = "r8169";
        networkConfig.Bond = "bond0";
      };
      "40-bond0" = {
        matchConfig.Name = "bond0";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
        linkConfig.RequiredForOnline = "routable";
        macvtap = [ "vm0" ];
      };
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    80
    443
    1883 # MQTT
    5970
    8080
    8234
    9898 # PeerBanHelper
    9000
    13831 # Snell
    8123 # Home Assistant
    21064 # Home Assistant HomeKit Bridge
    1400 # Home Assistant Sonos
    1443 # Home Assistant Sonos
    17650 # mihomo
  ];
  networking.firewall.allowedUDPPorts = [
    161 # SNMP
    162 # SNMP Trap
    5970
    13831 # Snell
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

}
