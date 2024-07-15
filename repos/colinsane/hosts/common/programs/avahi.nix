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
{ config, lib, ... }:
{
  sane.programs.avahi = {
    sandbox.method = "bwrap";
    sandbox.whitelistDbus = [ "system" ];
    sandbox.net = "all";  #< otherwise it will show 'null' in place of each interface name.
    sandbox.extraPaths = [
      "/"  #< else the daemon exits immediately. TODO: decrease this scope.
    ];
  };
  services.avahi = lib.mkIf config.sane.programs.avahi.enabled {
    enable = true;
    package = config.sane.programs.avahi.package;
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
}
