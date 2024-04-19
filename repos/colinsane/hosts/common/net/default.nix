{ lib, ... }:

{
  imports = [
    ./dns.nix
    ./hostnames.nix
    ./upnp.nix
    ./vpn.nix
  ];

  systemd.network.enable = true;
  networking.useNetworkd = true;

  # view refused/dropped packets with: `sudo journalctl -k`
  # networking.firewall.logRefusedPackets = true;
  # networking.firewall.logRefusedUnicastsOnly = false;
  networking.firewall.logReversePathDrops = true;
  # linux will drop inbound packets if it thinks a reply to that packet wouldn't exit via the same interface (rpfilter).
  #   that heuristic fails for complicated VPN-style routing, especially with SNAT.
  # networking.firewall.checkReversePath = false;  # or "loose" to keep it partially.
  # networking.firewall.enable = false;  #< set false to debug

  # this is needed to forward packets from the VPN to the host.
  # this is required separately by servo and by any `sane-vpn` users,
  # however Nix requires this be set centrally, in only one location (i.e. here)
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # the default backend is "wpa_supplicant".
  # wpa_supplicant reliably picks weak APs to connect to.
  # see: <https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/474>
  # iwd is an alternative that shouldn't have this problem
  # docs:
  # - <https://nixos.wiki/wiki/Iwd>
  # - <https://iwd.wiki.kernel.org/networkmanager>
  # - `man iwd.config`  for global config
  # - `man iwd.network` for per-SSID config
  # use `iwctl` to control
  # networking.networkmanager.wifi.backend = "iwd";
  # networking.wireless.iwd.enable = true;
  # networking.wireless.iwd.settings = {
  #   # auto-connect to a stronger network if signal drops below this value
  #   # bedroom -> bedroom connection is -35 to -40 dBm
  #   # bedroom -> living room connection is -60 dBm
  #   General.RoamThreshold = "-52";  # default -70
  #   General.RoamThreshold5G = "-52";  # default -76
  # };

  # plugins mostly add support for establishing different VPN connections.
  # the default plugin set includes mostly proprietary VPNs:
  # - fortisslvpn (Fortinet)
  # - iodine (DNS tunnels)
  # - l2tp
  # - openconnect (Cisco Anyconnect / Juniper / ocserv)
  # - openvpn
  # - vpnc (Cisco VPN)
  # - sstp
  #
  # i don't use these, and notably they drag in huge dependency sets and don't cross compile well.
  # e.g. openconnect drags in webkitgtk (for SSO)!
  networking.networkmanager.plugins = lib.mkForce [];

  # keyfile.path = where networkmanager should look for connection credentials
  networking.networkmanager.settings.keyfile.path = "/var/lib/NetworkManager/system-connections";
}
