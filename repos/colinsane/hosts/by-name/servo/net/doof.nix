{ config, ... }:
{
  # tun-sea config
  sane.dns.zones."uninsane.org".inet.A."doof.tunnel" = "205.201.63.12";
  # sane.dns.zones."uninsane.org".inet.AAAA."doof.tunnel" = "2602:fce8:106::51";  #< TODO: enable IPv6 (i have /128)

  # if the tunnel breaks, restart it manually:
  # - `systemctl restart netns-doof.service`
  sane.netns.doof = {
    veth.initns.ipv4 = "10.0.2.5";
    veth.netns.ipv4 = "10.0.2.6";
    routeTable = 12;
    wg.privateKeyFile = config.sops.secrets.wg_doof_privkey.path;
    wg.address.ipv4 = "205.201.63.12";
    wg.peer.publicKey = "nuESyYEJ3YU0hTZZgAd7iHBz1ytWBVM5PjEL1VEoTkU=";
    wg.peer.endpoint = "tun-sea.doof.net:53263";
    # wg.peer.endpoint = "205.201.63.44:53263";
  };

  # inside doof, forward DNS requests back to the root machine
  # this is fine: nothing inside the ns performs DNS except for wireguard,
  # and we're not forwarding external DNS requests here
  # XXX: ACTUALLY, CAN'T EASILY DO THAT BECAUSE HICKORY-DNS IS ALREADY USING PORT 53
  # but that's ok, we don't really need DNS *inside* this namespace.
  # sane.netns.doof.dns.ipv4 = config.sane.netns.doof.veth.netns.ipv4;
}
