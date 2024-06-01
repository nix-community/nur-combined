{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (pkgs) fetchgit;
  inherit (lib) mkBefore pipe filterAttrs;
  cfg = config.abszero.programs.firefox;

  firefox-vertical-tabs =
    with builtins;
    pipe ./lock.json [
      readFile
      fromJSON
      (filterAttrs (
        n: _:
        elem n [
          "url"
          "rev"
          "hash"
        ]
      ))
      fetchgit
    ];
in

{
  imports = [ ../../../programs/firefox.nix ];

  programs.firefox.profiles.${cfg.profile}.userChrome = mkBefore ''@import "${firefox-vertical-tabs}/userChrome.css";'';
}
