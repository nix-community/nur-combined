{ lib, ... }:
let
  networks = [
    {
      index = 1;
      priority = 1;
    }
    {
      index = 2;
      priority = 2;
    }
    {
      index = 3;
      network = 1;
      priority = 0;
      pmf = 1;
    }
    {
      index = 4;
      network = 2;
      priority = 0;
      pmf = 1;
    }
  ];
  stationProfile =
    {
      index,
      priority,
      network ? index,
      pmf ? 2,
    }:
    {
      name = "wifi-${toString index}";
      value = {
        connection = {
          id = "wifi-${toString index}";
          type = "wifi";
          interface-name = "wlan0";
          autoconnect = true;
          autoconnect-priority = priority;
          autoconnect-retries = 1;
          auth-retries = 1;
        };
        wifi = {
          mode = "infrastructure";
          ssid = "$WIFI_${toString network}_SSID";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$WIFI_${toString network}_PSK";
          # Disabling PMF also excludes SAE on the compatibility profiles.
          inherit pmf;
        };
        ipv4 = {
          method = "auto";
          dhcp-timeout = 30;
          may-fail = false;
        };
        ipv6.method = "auto";
      };
    };
in
{
  networking = {
    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
      settings.main.firewall-backend = "none";
      # An active hotspot stays up until: nmcli connection up wifi-1
      ensureProfiles.profiles = builtins.listToAttrs (map stationProfile networks) // {
        alpha-recovery = {
          connection = {
            id = "alpha-recovery";
            type = "wifi";
            interface-name = "wlan0";
            autoconnect = true;
            autoconnect-priority = -999;
          };
          wifi = {
            mode = "ap";
            ssid = "alpha-recovery";
            band = "bg";
            channel = 6;
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            proto = "rsn";
            pairwise = "ccmp";
            group = "ccmp";
            psk = "$RECOVERY_PSK";
          };
          ipv4 = {
            method = "shared";
            address1 = "10.42.0.1/24";
            never-default = true;
          };
          ipv6.method = "disabled";
        };
      };
    };

    # Recovery clients can reach Alpha, without routing through other interfaces.
    nftables.enable = true;
    firewall = {
      filterForward = true;
      allowedUDPPorts = lib.mkForce [ ];
      interfaces.wlan0 = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [
          53
          67
        ];
      };
    };
  };
}
