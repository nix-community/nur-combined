{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (builtins) readDir;
  inherit (lib) mkEnableOption mkIf singleton;
  cfg = config.abszero.boot.lanzaboote;
in

{
  options.abszero.boot.lanzaboote.enable = mkEnableOption "lanzaboote";

  config = mkIf cfg.enable {
    assertions = singleton {
      assertion =
        readDir ./pki/keys/db ? "db.key"
        && readDir ./pki/keys/KEK ? "KEK.key"
        && readDir ./pki/keys/PK ? "PK.key";
      message = "Secure boot keys are hidden, configuration cannot be activated";
    };
    boot.lanzaboote = {
      enable = true;
      # mode = "uki";
      configurationLimit = 5;
      pkiBundle = ./pki;
    };
    environment.systemPackages = with pkgs; [ sbctl ];
  };
}
