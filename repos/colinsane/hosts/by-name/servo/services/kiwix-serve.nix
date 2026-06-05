{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.sane.maxBuildCost >= 3) {
    services.kiwix-serve = {
      enable = true;
      port = 8013;
      library = lib.mapAttrs (k: v: v.zimPath) {
        inherit (pkgs.zimPackages)
          alpinelinux_en_all_maxi
          archlinux_en_all_maxi
          bitcoin_en_all_maxi
          devdocs_en_nix
          gentoo_en_all_maxi
          khanacademy_en_all
          openstreetmap-wiki_en_all_maxi
          psychonautwiki_en_all_maxi
          rationalwiki_en_all_maxi
          # wikipedia_en_100
          wikipedia_en_all_maxi
          # wikipedia_en_all_mini
          zimgit-food-preparation_en
          zimgit-medicine_en
          zimgit-post-disaster_en
          zimgit-water_en
        ;
      };
    };

    services.nginx.virtualHosts."w.uninsane.org" = {
      forceSSL = true;
      enableACME = true;
      # inherit kTLS;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8013";
        recommendedProxySettings = true;
      };
      locations."= /robots.txt".extraConfig = ''
        return 200 "User-agent: *\nDisallow: /\n";
      '';
    };

    sane.dns.zones."uninsane.org".inet.CNAME."w" = "native";
  };
}
