# Run locally: nix build --impure --file tests/alpha-wifi.nix
{
  flake ? builtins.getFlake (toString ../.),
  pkgs ? flake.inputs.nixpkgs.legacyPackages.${builtins.currentSystem},
  alpha ? flake.nixosConfigurations.alpha,
}:
let
  inherit (pkgs) lib;
  keys = import (pkgs.path + /nixos/tests/ssh-keys.nix) pkgs;
  credentials = pkgs.writeText "test-wifi.env" ''
    WIFI_1_SSID=normal-wifi
    WIFI_1_PSK=test-normal-password
    WIFI_2_SSID=absent-2
    WIFI_2_PSK=test-normal-password
    RECOVERY_PSK=test-recovery-password
  '';
  radio = index: {
    networking = {
      useDHCP = false;
      interfaces.eth1.ipv4.addresses = lib.mkForce [
        {
          address = "192.168.1.${toString index}";
          prefixLength = 24;
        }
      ];
    };
    services.vwifi = {
      module = {
        enable = true;
        macPrefix = "74:F8:F6:00:0${toString index}";
      };
      client = {
        enable = true;
        serverAddress = "192.168.1.1";
        serverPort = 8212;
      };
    };
    systemd.services.vwifi-client = {
      after = lib.mkForce [
        "network-addresses-eth1.service"
        "vwifi-add-interfaces.service"
      ];
      requires = lib.mkForce [ "network-addresses-eth1.service" ];
    };
    virtualisation.memorySize = 512;
  };
  managed = {
    networking.networkmanager = {
      enable = true;
      unmanaged = [
        "eth0"
        "eth1"
      ];
      logLevel = "INFO";
    };
    networking.wireless.enable = lib.mkOverride 0 true;
    systemd.services.NetworkManager.after = [ "vwifi-client.service" ];
  };
in
pkgs.testers.runNixOSTest {
  name = "alpha-wifi-recovery";
  globalTimeout = 900;
  nodes = {
    router = {
      imports = [ (radio 1) ];
      services = {
        vwifi.server = {
          enable = true;
          ports.tcp = 8212;
          openFirewall = true;
        };
        hostapd = {
          enable = true;
          radios.wlan0 = {
            band = "2g";
            channel = 6;
            countryCode = "US";
            networks.wlan0 = {
              ssid = "normal-wifi";
              # Frequent beacons tolerate the virtual radio transport's latency.
              settings.beacon_int = 20;
              authentication = {
                mode = "wpa3-sae-transition";
                wpaPassword = "test-normal-password";
                saePasswords = [ { password = "test-normal-password"; } ];
              };
            };
          };
        };
        dnsmasq = {
          enable = true;
          settings = {
            interface = "wlan0";
            bind-dynamic = true;
            dhcp-range = "192.168.50.50,192.168.50.100,255.255.255.0,1h";
            dhcp-option = [
              "3"
              "6"
            ];
          };
        };
      };
      systemd.services.hostapd.after = [ "vwifi-client.service" ];
      networking.interfaces.wlan0.ipv4.addresses = [
        {
          address = "192.168.50.1";
          prefixLength = 24;
        }
      ];
      networking.firewall.interfaces.wlan0.allowedUDPPorts = [ 67 ];
    };
    alpha = {
      imports = [
        (radio 2)
        managed
        ../nixos/hosts/alpha/wifi.nix
      ];
      networking.networkmanager.ensureProfiles.environmentFiles = [ credentials ];
      services.openssh = {
        enable = true;
        inherit (alpha.config.services.openssh) ports;
        settings = builtins.removeAttrs alpha.config.services.openssh.settings [ "ModuliFile" ];
      };
      users.users.iamanaws = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ keys.snakeOilEd25519PublicKey ];
      };
      security.sudo.wheelNeedsPassword = false;
    };
    client = {
      imports = [
        (radio 3)
        managed
      ];
      networking.networkmanager.ensureProfiles.profiles.repair = {
        connection = {
          id = "repair";
          type = "wifi";
          interface-name = "wlan0";
          autoconnect = false;
          auth-retries = 1;
        };
        wifi.ssid = "alpha-recovery";
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "test-recovery-password";
        };
        ipv4.method = "auto";
        ipv6.method = "disabled";
      };
      environment.etc."test-key" = {
        source = keys.snakeOilEd25519PrivateKey;
        mode = "0600";
      };
    };
  };
  testScript = ''
    from datetime import timedelta

    def active(name):
        try:
            alpha.wait_until_succeeds(
                "nmcli -g GENERAL.STATE device show wlan0 | grep -q '^100 ' && "
                f"nmcli -g GENERAL.CONNECTION device show wlan0 | grep -Fx '{name}'",
                timeout=timedelta(seconds=90),
            )
        except Exception:
            alpha.log(alpha.succeed("journalctl -b -u NetworkManager -u wpa_supplicant --no-pager"))
            alpha.log(alpha.succeed("nmcli device wifi list; nmcli connection show"))
            raise

    ssh = "ssh -p 3939 -i /etc/test-key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o BatchMode=yes -o ConnectTimeout=5 iamanaws@10.42.0.1"

    def repair_access():
        client.wait_until_succeeds("nmcli --wait 20 connection up repair", timeout=timedelta(seconds=60))
        client.succeed("ip -4 addr show wlan0 | grep '10.42.0.'")
        client.succeed(f"{ssh} 'test $(id -un) = iamanaws'")

    router.start()
    router.wait_for_unit("hostapd.service")
    router.wait_for_unit("dnsmasq.service")
    router.wait_for_open_port(8212)
    router.wait_until_succeeds("${pkgs.hostapd}/bin/hostapd_cli -i wlan0 status | grep -Fx 'state=ENABLED'")
    router.wait_until_succeeds("journalctl -b -u vwifi-client --grep='Connection to Server Ok' --quiet")
    alpha.start(allow_reboot=True)
    alpha.wait_for_unit("NetworkManager.service")

    with subtest("Saved Wi-Fi wins at boot, without requiring Internet access"):
        active("wifi-1")
        alpha.succeed("ping -c 1 -I wlan0 192.168.50.1")
        router.succeed("${pkgs.hostapd}/bin/hostapd_cli -i wlan0 all_sta | grep -Fx 'auth_alg=3'")
        alpha.succeed("test $(stat -c %a /run/NetworkManager/system-connections/alpha-recovery.nmconnection) = 600")

    with subtest("Saved Wi-Fi remains preferred across reboots"):
        for _ in range(2):
            alpha.reboot()
            active("wifi-1")

    with subtest("A failed primary profile tries the compatibility profile before recovery"):
        alpha.succeed("nmcli connection modify wifi-1 wifi-sec.psk incorrect-password")
        alpha.fail("nmcli --wait 90 connection up wifi-1", timeout=100)
        active("wifi-3")
        alpha.succeed("ping -c 1 -I wlan0 192.168.50.1")
        router.succeed("${pkgs.hostapd}/bin/hostapd_cli -i wlan0 all_sta | grep -Fx 'auth_alg=0'")
        alpha.succeed("nmcli connection modify wifi-1 wifi-sec.psk test-normal-password")
        alpha.succeed("nmcli --wait 60 connection up wifi-1")
        active("wifi-1")

    with subtest("Losing Wi-Fi starts the encrypted recovery hotspot"):
        router.systemctl("stop hostapd.service")
        active("alpha-recovery")
        alpha.succeed("${pkgs.iw}/bin/iw dev wlan0 info | grep 'type AP'")
        client.start()
        client.wait_for_unit("NetworkManager.service")
        client.wait_until_succeeds("nmcli connection show repair")
        client.wait_until_succeeds("nmcli -g SSID device wifi list --rescan yes | grep -Fx alpha-recovery")
        client.succeed("nmcli connection modify repair wifi-sec.psk incorrect-password")
        client.fail("nmcli --wait 60 connection up repair", timeout=70)
        client.succeed("journalctl -b -u wpa_supplicant --grep='WRONG_KEY|CTRL-EVENT-AUTH-REJECT.*auth_type=3' --quiet")
        client.succeed("nmcli connection modify repair wifi-sec.psk test-recovery-password")
        repair_access()

    with subtest("Recovery stays active when the saved network returns"):
        router.systemctl("start hostapd.service")
        client.succeed(f"{ssh} 'sudo systemctl restart NetworkManager-ensure-profiles; sleep 40; echo still-connected'", timeout=60)
        active("alpha-recovery")

    with subtest("Recovery does not route clients into another network"):
        client.succeed("ip route add 198.51.100.1/32 via 10.42.0.1 dev wlan0")
        router.succeed("ip addr add 198.51.100.1/32 dev lo")
        router.succeed("ip route add 10.42.0.0/24 via 192.168.1.2")
        alpha.succeed("ip route add 198.51.100.1/32 via 192.168.1.1")
        alpha.succeed("ping -c 1 198.51.100.1")
        client.fail("ping -c 1 -W 2 198.51.100.1")

    with subtest("An explicit retry switches back to normal Wi-Fi"):
        client.execute(f"{ssh} 'sudo nmcli --wait 0 connection up wifi-1'")
        active("wifi-1")
        alpha.succeed("ping -c 1 -I wlan0 192.168.50.1")

    with subtest("Incorrect saved credentials fall back to recovery"):
        alpha.succeed("nmcli connection modify wifi-1 wifi-sec.psk incorrect-password")
        alpha.succeed("nmcli connection modify wifi-3 wifi-sec.psk incorrect-password")
        alpha.fail("nmcli --wait 90 connection up wifi-1", timeout=100)
        active("alpha-recovery")
        repair_access()

    with subtest("Association without DHCP falls back to recovery"):
        router.systemctl("stop dnsmasq.service")
        alpha.succeed("nmcli connection modify wifi-1 wifi-sec.psk test-normal-password")
        alpha.succeed("nmcli connection modify wifi-3 wifi-sec.psk test-normal-password")
        alpha.fail("nmcli --wait 90 connection up wifi-1", timeout=100)
        active("alpha-recovery")
        repair_access()

    with subtest("A failed retry remains repairable and a later retry succeeds"):
        router.systemctl("start dnsmasq.service")
        alpha.succeed("nmcli --wait 60 connection up wifi-1")
        active("wifi-1")

    with subtest("Booting without any saved network also starts recovery"):
        router.systemctl("stop hostapd.service")
        alpha.reboot()
        active("alpha-recovery")
        repair_access()
  '';
}
