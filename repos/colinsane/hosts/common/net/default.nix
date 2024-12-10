{ ... }:

{
  imports = [
    ./dns
    ./hostnames.nix
    ./modemmanager.nix
    ./networkmanager.nix
    ./ntp.nix
    ./upnp.nix
    ./vpn.nix
  ];

  systemd.network.enable = true;
  networking.useNetworkd = true;
  networking.usePredictableInterfaceNames = false;  #< set false to get `eth0`, `wlan0`, etc instead of `enp3s0`/etc

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
}
