# TURN/STUN NAT traversal service
# commonly used to establish realtime calls with prosody, or possibly matrix/synapse
#
# - <https://github.com/coturn/coturn/>
# - `man turnserver`
# - config docs: <https://github.com/coturn/coturn/blob/master/examples/etc/turnserver.conf>
#
# N.B. during operation it's NORMAL to see "error 401".
# during session creation:
# - client sends Allocate request
# - server replies error 401, providing a realm and nonce
# - client uses realm + nonce + shared secret to construct an auth key & call Allocate again
# - server replies Allocate Success Response
# - source: <https://stackoverflow.com/a/66643135>
#
# N.B. this safest implementation routes all traffic THROUGH A VPN
# - that adds a lot of latency, but in practice turns out to be inconsequential.
#   i guess ICE allows clients to prefer the other party's lower-latency server, in practice?
# - still, this is the "safe" implementation because STUN works with IP addresses instead of domain names:
#   1. client A queries the STUN server to determine its own IP address/port.
#   2. client A tells client B which IP address/port client A is visible on.
#   3. client B contacts that IP address/port
#   this only works so long as the IP address/port which STUN server sees client A on is publicly routable.
#   that is NOT the case when the STUN server and client A are on the same LAN
#   even if client A contacts the STUN server via its WAN address with port reflection enabled.
#   hence, there's no obvious way to put the STUN server on the same LAN as either client and expect the rest to work.
# - there an old version which *half worked*, which is:
#   - run the turn server in the root namespace.
#   - bind the turn server to the veth connecting it to the VPN namespace (so it sends outgoing traffic to the right place).
#   - NAT the turn port range from VPN into root namespace (so it receives incomming traffic).
#   - this approach would fail the prosody conversations.im check, but i didn't notice *obvious* call routing errors.
#
# debugging:
# - log messages like 'usage: realm=<turn.uninsane.org>, username=<1715915193>, rp=14, rb=1516, sp=8, sb=684'
#   - rp = received packets
#   - rb = received bytes
#   - sp = sent packets
#   - sb = sent bytes

{ config, lib, ... }:
let
  # TURN port range (inclusive).
  # default coturn behavior is to use the upper quarter of all ports. i.e. 49152 - 65535.
  # i believe TURN allocations expire after either 5 or 10 minutes of inactivity.
  turnPortLow = 49152; # 49152 = 0xc000
  turnPortHigh = turnPortLow + 256;
  turnPortRange = lib.range turnPortLow turnPortHigh;
in
{
  # the port definitions are only needed if running in the root net namespace
  # sane.ports.ports = lib.mkMerge ([
  #   {
  #     "3478" = {
  #       # this is the "control" port.
  #       # i.e. no client data is forwarded through it, but it's where clients request tunnels.
  #       protocol = [ "tcp" "udp" ];
  #       # visibleTo.lan = true;
  #       # visibleTo.wan = true;
  #       visibleTo.ovpns = true;  # forward traffic from the VPN to the root NS
  #       description = "colin-stun-turn";
  #     };
  #     "5349" = {
  #       # the other port 3478 also supports TLS/DTLS, but presumably clients wanting TLS will default 5349
  #       protocol = [ "tcp" ];
  #       # visibleTo.lan = true;
  #       # visibleTo.wan = true;
  #       visibleTo.ovpns = true;
  #       description = "colin-stun-turn-over-tls";
  #     };
  #   }
  # ] ++ (builtins.map
  #   (port: {
  #     "${builtins.toString port}" = let
  #       count = port - turnPortLow + 1;
  #       numPorts = turnPortHigh - turnPortLow + 1;
  #     in {
  #       protocol = [ "tcp" "udp" ];
  #       # visibleTo.lan = true;
  #       # visibleTo.wan = true;
  #       visibleTo.ovpns = true;
  #       description = "colin-turn-${builtins.toString count}-of-${builtins.toString numPorts}";
  #     };
  #   })
  #   turnPortRange
  # ));

  services.nginx.virtualHosts."turn.uninsane.org" = {
    # allow ACME to procure a cert via nginx for this domain
    enableACME = true;
  };
  sane.dns.zones."uninsane.org".inet = {
    # CNAME."turn" = "servo.wan";
    # CNAME."turn" = "ovpns";
    # CNAME."turn" = "native";
    # XXX: SRV records have to point to something with a A/AAAA record; no CNAMEs
    A."turn" = "%AOVPNS%";
    # A."turn" = "%AWAN%";

    SRV."_stun._udp" =                        "5 50 3478 turn";
    SRV."_stun._tcp" =                        "5 50 3478 turn";
    SRV."_stuns._tcp" =                       "5 50 5349 turn";
    SRV."_turn._udp" =                        "5 50 3478 turn";
    SRV."_turn._tcp" =                        "5 50 3478 turn";
    SRV."_turns._tcp" =                       "5 50 5349 turn";
  };

  # provide access to certs
  users.users.turnserver.extraGroups = [ "nginx" ];

  services.coturn.enable = true;
  services.coturn.realm = "turn.uninsane.org";
  services.coturn.cert = "/var/lib/acme/turn.uninsane.org/fullchain.pem";
  services.coturn.pkey = "/var/lib/acme/turn.uninsane.org/key.pem";

  # N.B.: prosody needs to read this shared secret
  sops.secrets."coturn_shared_secret".owner = "turnserver";
  sops.secrets."coturn_shared_secret".group = "turnserver";
  sops.secrets."coturn_shared_secret".mode = "0440";

  #v disable to allow unauthenticated access (or set `services.coturn.no-auth = true`)
  services.coturn.use-auth-secret = true;
  services.coturn.static-auth-secret-file = "/run/secrets/coturn_shared_secret";
  services.coturn.lt-cred-mech = true; #< XXX: use-auth-secret overrides lt-cred-mech

  services.coturn.min-port = turnPortLow;
  services.coturn.max-port = turnPortHigh;
  # services.coturn.secure-stun = true;
  services.coturn.extraConfig = lib.concatStringsSep "\n" [
    "verbose"
    # "Verbose"  #< even MORE verbosity than "verbose"  (it's TOO MUCH verbosity really)
    "no-multicast-peers"  # disables sending to IPv4 broadcast addresses (e.g. 224.0.0.0/3)
    # "listening-ip=${config.sane.netns.ovpns.veth.initns.ipv4}" "external-ip=${config.sane.netns.ovpns.wg.address.ipv4}"  #< 2024/04/25: works, if running in root namespace
    "listening-ip=${config.sane.netns.ovpns.wg.address.ipv4}" "external-ip=${config.sane.netns.ovpns.wg.address.ipv4}"

    # old attempts:
    # "external-ip=${config.sane.netns.ovpns.wg.address.ipv4}/${config.sane.netns.ovpns.veth.initns.ipv4}"
    # "listening-ip=10.78.79.51"  # can be specified multiple times; omit for *
    # "external-ip=97.113.128.229/10.78.79.51"
    # "external-ip=97.113.128.229"
    # "mobility"  # "mobility with ICE (MICE) specs support" (?)
  ];
  systemd.services.coturn.serviceConfig.NetworkNamespacePath = "/run/netns/ovpns";
}
