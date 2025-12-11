{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.boot.lanzaboote;
in

{
  options.abszero.boot.lanzaboote.enable = mkEnableOption "lanzaboote";

  config = mkIf cfg.enable {
    boot.lanzaboote = {
      enable = true;
      # mode = "uki";
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        includeMicrosoftKeys = false;
        allowBrickingMyMachine = true; # Double confirm not including Microsoft keys
      };
    };
    environment.systemPackages = with pkgs; [ sbctl ];
  };
}
