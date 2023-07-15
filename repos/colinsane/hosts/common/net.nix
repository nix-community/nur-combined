{ lib, ... }:

{
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

  networking.firewall.allowedUDPPorts = [
    1900  # to received UPnP advertisements. required by sane-ip-check-upnp
  ];

  # keyfile.path = where networkmanager should look for connection credentials
  networking.networkmanager.extraConfig = ''
    [keyfile]
    path=/var/lib/NetworkManager/system-connections
  '';
}
