{ ... }:
{
  sane.services.kiwix-serve = {
    enable = true;
    port = 8013;
    zimPaths = [ "/var/lib/uninsane/www-archive/wikipedia_en_all_maxi_2022-05.zim" ];
  };

  services.nginx.virtualHosts."w.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    # inherit kTLS;
    locations."/".proxyPass = "http://127.0.0.1:8013";
  };

  sane.services.trust-dns.zones."uninsane.org".inet.CNAME."w" = "native";
}
