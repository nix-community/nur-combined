{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (pkgs) fetchgit;
  inherit (lib)
    mkBefore
    mkIf
    pipe
    filterAttrs
    ;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.base.firefox;
  firefoxCfg = config.abszero.programs.firefox;

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
  imports = [
    ../../../../../lib/modules/config/abszero.nix
    ../../../programs/firefox.nix
  ];

  options.abszero.themes.base.firefox.verticalTabs =
    mkExternalEnableOption config "firefox vertical tabs";

  config.programs.firefox.profiles.${firefoxCfg.profile}.userChrome = mkIf cfg.verticalTabs (
    mkBefore ''@import "${firefox-vertical-tabs}/userChrome.css";''
  );
}
