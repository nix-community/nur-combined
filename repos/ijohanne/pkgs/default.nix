{ pkgs, sources, ... }:
{
  sddmThemes = pkgs.libsForQt5.callPackage ./sddm-themes { inherit sources; };
  fishPlugins = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./fish-plugins { inherit pkgs sources; });
  vimPlugins = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./vim-plugins { inherit pkgs sources; });
  firefoxPlugins = pkgs.lib.recurseIntoAttrs (pkgs.callPackage ./firefox-plugins { });
  firefox-hardened = pkgs.callPackage ./firefox-hardened { inherit pkgs; };
  hexokinase = pkgs.callPackage ./hexokinase { inherit pkgs sources; };
  nixpkgs-firefox-addons = pkgs.haskellPackages.callPackage ./firefox-addons-generator { inherit sources; };
  prometheus-teamspeak3-exporter = pkgs.callPackage ./prometheus-teamspeak3-exporter { inherit pkgs sources; };
  prometheus-gpsd-exporter = pkgs.callPackage ./prometheus-gpsd-exporter { inherit pkgs sources; };
  prometheus-hue-exporter = pkgs.callPackage ./prometheus-hue-exporter { inherit pkgs sources; };
  prometheus-nftables-exporter = pkgs.callPackage ./prometheus-nftables-exporter { inherit pkgs sources; };
  prometheus-netatmo-exporter = pkgs.callPackage ./prometheus-netatmo-exporter { inherit pkgs sources; };
  multicast-relay = pkgs.callPackage ./multicast-relay { inherit pkgs sources; };
  pg-exporter = pkgs.callPackage ./pg-exporter { inherit pkgs sources; };
  agent-skills-cli = pkgs.callPackage ./agent-skills-cli { inherit pkgs sources; };
  zot = pkgs.callPackage ./zot { inherit pkgs sources; };
}
