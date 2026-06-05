# Avahi zeroconf (mDNS) implementation.
# runs as systemd `avahi-daemon.service`
#
# - <https://avahi.org/>
# - code: <https://github.com/avahi/avahi>
# - IRC: #avahi on irc.libera.chat
#
# - `avahi-browse --help` for usage
# - `man avahi-daemon.conf`
# - `LD_LIBRARY_PATH=/nix/store/ngwj3jqmxh8k4qji2z0lj7y1f8vzqrn2-nss-mdns-0.15.1/lib getent hosts desko.local`
#   nss-mdns goes through avahi-daemon, so there IS caching here
#
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.avahi;
in
{
  sane.programs.avahi = {
    packageUnwrapped = pkgs.avahi.overrideAttrs (upstream: {
      # avahi wants to do its own sandboxing opaque to systemd & maybe in conflict with my bwrap.
      # --no-drop-root disables that, so that i can e.g. run it as User=avahi, etc.
      # do this here, because the nixos service isn't so easily patched.
      postInstall = (upstream.postInstall or "") + ''
        wrapProgram "$out/sbin/avahi-daemon" \
          --add-flag --no-drop-root
      '';
      nativeBuildInputs = upstream.nativeBuildInputs ++ [
        pkgs.makeBinaryWrapper
      ];
    });
    sandbox.whitelistDbus.system = true;
    sandbox.net = "all";  #< otherwise it will show 'null' in place of each interface name.
    # sandbox.extraPaths = [ ];  #< may be missing some paths; only tried service discovery, not service advertisement.
  };

  services.avahi = lib.mkIf cfg.enabled {
    enable = true;
    package = cfg.packageUnwrapped;  #< use systemd sandboxing... not my own
    publish.enable = true;
    publish.userServices = true;
    nssmdns4 = true;
    nssmdns6 = true;
    # reflector = true;
    allowInterfaces = [
      # particularly, the default config disallows loopback, which is kinda fucking retarded, right?
      "ens1"  #< servo
      "enp5s0"  #< desko
      "eth0"
      "lo"
      "wg-home"
      "wlan0"  #< moby
      "wlp3s0"  #< lappy
      "wlp4s0"  #< desko
    ];
  };

  # fix "rpfilter drop ..." dmesg logspam.
  # this might not be necessary?
  networking.firewall.extraCommands = lib.mkIf cfg.enabled (with pkgs; ''
    # after an outgoing mDNS query to the multicast address, open FW for incoming responses.
    # ipset -! means "don't fail if set already exists"
    ${lib.getExe' ipset "ipset"} create -! mdns hash:ip,port timeout 10
    ${lib.getExe' iptables "iptables"} -A OUTPUT -d 239.255.255.250/32 -p udp -m udp --dport 5353 -j SET --add-set mdns src,src --exist
    ${lib.getExe' iptables "iptables"} -A INPUT -p udp -m set --match-set mdns dst,dst -j ACCEPT
    # IPv6 ruleset. ff02::/16 means *any* link-local multicast group (so this is probably more broad than it needs to be)
    ${lib.getExe' ipset "ipset"} create -! mdns6 hash:ip,port timeout 10 family inet6
    ${lib.getExe' iptables "ip6tables"} -A OUTPUT -d ff02::/16 -p udp -m udp --dport 5353 -j SET --add-set mdns6 src,src --exist
    ${lib.getExe' iptables "ip6tables"} -A INPUT -p udp -m set --match-set mdns6 dst,dst -j ACCEPT
  '');

  systemd.services.avahi-daemon = lib.mkIf cfg.enabled {
    # hardening: see `systemd-analyze security avahi-daemon`
    serviceConfig.User = "avahi";
    serviceConfig.Group = "avahi";
    serviceConfig.AmbientCapabilities = "";
    serviceConfig.CapabilityBoundingSet = lib.mkForce "";
    serviceConfig.PrivateUsers = lib.mkForce true;
  };
}
