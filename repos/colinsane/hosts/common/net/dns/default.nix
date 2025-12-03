# things to consider when changing these parameters:
# - temporary VPN access (`sane-vpn up ...`)
# - servo `ovpns` namespace (it *relies* on /etc/resolv.conf mentioning 127.0.0.53)
#
# components:
# - /etc/nsswitch.conf:
#   - glibc uses this to provide `getaddrinfo`, i.e. host -> ip address lookup
#     call directly with `getent ahostsv4 www.google.com`
#   - `nss` (a component of glibc) is modular: names mentioned in that file are `dlopen`'d (i think that's the mechanism)
#     in NixOS, that means _they have to be on LDPATH_.
#   - `nscd` is used by NixOS simply to proxy nss requests.
#      here, /etc/nsswitch.conf consumers contact nscd via /var/run/nscd/socket.
#      in this way, only `nscd` needs to have the nss modules on LDPATH.
# - /etc/resolv.conf
#   - contains the DNS servers for a system.
#   - historically, NetworkManager would update this file as you switch networks.
#   - modern implementations hardcodes `127.0.0.53` and then systemd-resolved proxies everything (and caches).
#
# namespacing:
# - each namespace may use a different /etc/resolv.conf to specify different DNS servers
# - nscd breaks namespacing: the host nscd is unaware of the guest's /etc/resolv.conf, and so directs the guest's DNS requests to the host's servers.
#   - this is fixed by either removing `/var/run/nscd/socket` from the namespace, or disabling nscd altogether.
{ config, pkgs, ... }:
{
  imports = [
    ./bind.nix
    ./hickory-dns.nix
    ./kresd.nix
    ./unbound.nix
  ];

  # nscd -- the Name Service Caching Daemon -- caches DNS query responses
  # in a way that's unaware of my VPN routing, so routes are frequently poor against
  # services which advertise different IPs based on geolocation.
  # nscd claims to be usable without a cache, but in practice i can't get it to not cache!
  # nsncd is the Name Service NON-Caching Daemon. it's a drop-in that doesn't cache;
  # this is OK on the host -- because systemd-resolved caches. it's probably sub-optimal
  # in the netns and we query upstream DNS more often than needed. hm.
  # services.nscd.enableNsncd = true;

  # disabling nscd LOSES US SOME FUNCTIONALITY. in particular, only the glibc-builtin modules are accessible via /etc/resolv.conf (er, did i mean /etc/nsswitch.conf?).
  # - dns: glibc-bultin
  # - files: glibc-builtin
  # - myhostname: systemd
  # - mymachines: systemd
  # - resolve: systemd
  # in practice, i see no difference with nscd disabled.
  # - the exception is when the system dns resolver doesn't do everything.
  #   for example, systemd-resolved does mDNS. hickory-dns does not. a hickory-dns system won't be mDNS-capable.
  # disabling nscd VASTLY simplifies netns and process isolation. see explainer at top of file.
  services.nscd.enable = false;
  # system.nssModules = lib.mkForce [];
  sane.silencedAssertions = [''.*Loading NSS modules from system.nssModules.*requires services.nscd.enable being set to true.*''];

  # add NSS modules into their own subdirectory.
  # then i can add just the NSS modules library path to the global LD_LIBRARY_PATH, rather than ALL of /run/current-system/sw/lib.
  # TODO: i'm doing this so as to achieve mdns DNS resolution (avahi). it would be better to just have hickory-dns delegate .local to avahi
  #   (except avahi doesn't act as a local resolver over DNS protocol -- only dbus).
  environment.systemPackages = [(pkgs.symlinkJoin {
    name = "nss-modules";
    paths = config.system.nssModules.list;
    postBuild = ''
      mkdir nss
      mv $out/lib/libnss_* nss
      rm -rf $out
      mkdir -p $out/lib
      mv nss $out/lib
    '';
  })];
  environment.variables.LD_LIBRARY_PATH = [ "/run/current-system/sw/lib/nss" ];
  systemd.globalEnvironment.LD_LIBRARY_PATH = "/run/current-system/sw/lib/nss";  #< specifically for `geoclue.service`
}
