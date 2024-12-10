{ config, lib, ... }:
lib.mkIf false  #< XXX(2024-10-xx): hickory-dns recursive resolution is too immature; switched to `unbound`
(lib.mkMerge [
 {
   sane.services.hickory-dns.enable = lib.mkDefault config.sane.services.hickory-dns.asSystemResolver;
   # sane.services.hickory-dns.asSystemResolver = lib.mkDefault true;
 }
 (lib.mkIf (!config.sane.services.hickory-dns.asSystemResolver && config.sane.services.hickory-dns.enable) {
   # use systemd's stub resolver.
   # /etc/resolv.conf isn't sophisticated enough to use different servers per net namespace (or link).
   # instead, running the stub resolver on a known address in the root ns lets us rewrite packets
   # in servo's ovnps namespace to use the provider's DNS resolvers.
   # a weakness is we can only query 1 NS at a time (unless we were to clone the packets?)
   # TODO: improve hickory-dns recursive resolver and then remove this
   services.resolved.enable = true;  #< to disable, set ` = lib.mkForce false`, as other systemd features default to enabling `resolved`.
   # without DNSSEC:
   # - dig matrix.org => works
   # - curl https://matrix.org => works
   # with default DNSSEC:
   # - dig matrix.org => works
   # - curl https://matrix.org => fails
   # i don't know why. this might somehow be interfering with the DNS run on this device (hickory-dns)
   services.resolved.dnssec = "false";
   networking.nameservers = [
     # use systemd-resolved resolver
     # full resolver (which understands /etc/hosts) lives on 127.0.0.53
     # stub resolver (just forwards upstream) lives on 127.0.0.54
     "127.0.0.53"
   ];
 })
])
