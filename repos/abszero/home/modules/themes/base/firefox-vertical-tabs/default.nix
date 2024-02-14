{ config, pkgs, lib, ... }:

let
  inherit (pkgs) fetchFromGitHub;
  inherit (lib) mkBefore pipe;
  cfg = config.abszero.programs.firefox;

  firefox-vertical-tabs = with builtins;
    pipe ./lock.json [
      readFile
      fromJSON
      fetchFromGitHub
    ];
in

{
  imports = [ ../../../programs/firefox.nix ];

  programs.firefox.profiles.${cfg.profile}.userChrome =
    mkBefore ''@import "${firefox-vertical-tabs}/userChrome.css";'';
}
