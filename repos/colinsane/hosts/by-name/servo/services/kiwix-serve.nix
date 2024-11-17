{ pkgs, ... }:
{
  sane.services.kiwix-serve = {
    enable = true;
    port = 8013;
    zimPaths = [
      "${pkgs.zimPackages.wikipedia_en_all_maxi}/share/zim/wikipedia_en_all_maxi.zim"
    ];
  };

  services.nginx.virtualHosts."w.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    # inherit kTLS;
    locations."/".proxyPass = "http://127.0.0.1:8013";
    locations."= /robots.txt".extraConfig = ''
      return 200 "User-agent: *\nDisallow: /\n";
    '';
  };

  sane.dns.zones."uninsane.org".inet.CNAME."w" = "native";
}
