{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.services.printing;
in

{
  options.abszero.services.printing.enable = mkEnableOption "printer support with CUPS";

  config.services = mkIf cfg.enable {
    printing.enable = true;
    avahi.enable = true; # This also enables cups-browsed
  };
}
