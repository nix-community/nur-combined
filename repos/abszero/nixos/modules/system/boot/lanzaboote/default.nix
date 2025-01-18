{
  config,
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
        readDir ./secureboot/keys/db ? "db.key"
        && readDir ./secureboot/keys/KEK ? "KEK.key"
        && readDir ./secureboot/keys/PK ? "PK.key";
      message = "Secure boot keys are hidden, configuration cannot be activated";
    };
    boot.lanzaboote = {
      enable = true;
      mode = "uki";
      configurationLimit = 5;
      pkiBundle = ./secureboot;
    };
  };
}
