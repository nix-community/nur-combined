{ config, pkgs, ... }:
let
  wakaLakaOsaka = pkgs.linkFarm "waka-laka-osaka" {
    "index.html" = ./index.html;
    "waka.laka.for.osaka.mp4" = pkgs.fetchurl {
      # saved from: <https://www.youtube.com/watch?v=ehB_7bBKprY>
      url = "https://uninsane.org/share/Milkbags/PG_Plays_Video_Games-Waka_Laka_For_Osaka_4K.mp4";
      hash = "sha256-UW0qR4btX4pZ1bJp4Oxk20m3mvQGj9HweLKO27JBTFs=";
    };
  };
in
{
  services.nginx.virtualHosts."laka.osaka" = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      # redirect everything to waka.laka.osaka
      return = "301 https://waka.laka.osaka$request_uri";
    };
  };
  services.nginx.virtualHosts."waka.laka.osaka" = {
    addSSL = true;
    enableACME = true;
    root = wakaLakaOsaka;

    locations."= /" = {
      # serving the file directly causes it to auto-play in both Firefox/Linux and Safari/iOS,
      # but maybe not in Android.
      tryFiles = "/waka.laka.for.osaka.mp4 =404";
      # `Content-Disposition: inline` otherwise iOS will want to download instead of playing.
      extraConfig = ''
        add_header Content-Disposition inline;
      '';
    };
  };

  sane.dns.zones."laka.osaka".inet = {
    SOA."@" = config.sane.dns.zones."uninsane.org".inet.SOA."@";
    A."@" = config.sane.dns.zones."uninsane.org".inet.A."@";
    NS."@" = config.sane.dns.zones."uninsane.org".inet.NS."@";
    CNAME."waka" = "native.uninsane.org.";
  };
}
