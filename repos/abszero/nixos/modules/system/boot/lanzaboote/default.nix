{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.boot.lanzaboote;
in

{
  options.abszero.boot.lanzaboote.enable = mkEnableOption "lanzaboote";

  config.boot.lanzaboote = mkIf cfg.enable {
    enable = true;
    mode = "uki";
    configurationLimit = 5;
    pkiBundle = ./secureboot;
  };
}
