{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.sane.maxBuildCost >= 3) {
    sane.services.kiwix-serve = {
      enable = true;
      port = 8013;
      zimPaths = with pkgs.zimPackages; [
        alpinelinux_en_all_maxi.zimPath
        archlinux_en_all_maxi.zimPath
        bitcoin_en_all_maxi.zimPath
        devdocs_en_nix.zimPath
        gentoo_en_all_maxi.zimPath
        # khanacademy_en_all.zimPath  #< TODO: enable
        openstreetmap-wiki_en_all_maxi.zimPath
        psychonautwiki_en_all_maxi.zimPath
        rationalwiki_en_all_maxi.zimPath
        # wikipedia_en_100.zimPath
        wikipedia_en_all_maxi.zimPath
        # wikipedia_en_all_mini.zimPath
        zimgit-food-preparation_en.zimPath
        zimgit-medicine_en.zimPath
        zimgit-post-disaster_en.zimPath
        zimgit-water_en.zimPath
      ];
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
