{ config, lib, ... }:

let
  cweb-cfg = config.services.calibre-web;
  inherit (cweb-cfg) user group;
  inherit (cweb-cfg.listen) ip port;
  svc-dir = "/var/lib/${cweb-cfg.dataDir}";
in
# XXX: disabled because of runtime errors like:
# > File "/nix/store/c7jqvx980nlg9xhxi065cba61r2ain9y-calibre-web-0.6.19/lib/python3.10/site-packages/calibreweb/cps/db.py", line 926, in speaking_language
# > languages = self.session.query(Languages) \
# > AttributeError: 'NoneType' object has no attribute 'query'
lib.mkIf false
{
  sane.persist.sys.plaintext = [
    { inherit user group; mode = "0700"; directory = svc-dir; }
  ];

  services.calibre-web.enable = true;
  services.calibre-web.listen.ip = "127.0.0.1";
  # XXX: externally populate `${svc-dir}/metadata.db` (once) from
  #   <https://github.com/janeczku/calibre-web/blob/master/library/metadata.db>
  # i don't know why you have to do this??
  # services.calibre-web.options.calibreLibrary = svc-dir;

  services.nginx.virtualHosts."calibre.uninsane.org" = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${ip}:${builtins.toString port}";
    };
  };
  sane.services.trust-dns.zones."uninsane.org".inet.CNAME."calibre" = "native";
}
