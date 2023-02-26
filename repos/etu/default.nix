{pkgs ? import <nixpkgs> {}, ...}: {
  chalet = pkgs.callPackage ./pkgs/chalet {};
  font-etuvetica = pkgs.callPackage ./pkgs/font-etuvetica {};
  font-talyznewroman = pkgs.callPackage ./pkgs/font-talyznewroman {};
  g90updatefw = pkgs.callPackage ./pkgs/g90updatefw {};
  llr = pkgs.callPackage ./pkgs/llr {};
  mkvcleaner = pkgs.callPackage ./pkgs/mkvcleaner {};

  # Firefox extensions
  firefox-extension-elasticvue = pkgs.callPackage ./pkgs/firefox-extensions/elasticvue.nix {};
  firefox-extension-streetpass-for-mastodon = pkgs.callPackage ./pkgs/firefox-extensions/streetpass-for-mastodon.nix {};
}
