{ config, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.abszero.boot.plymouth;
in

{
  options.abszero.boot.plymouth.enable = mkEnableOption "boot splash";

  config = mkIf cfg.enable {
    abszero.boot.quiet = true;
    boot = {
      plymouth.enable = true;
      kernelParams = [ "plymouth.use-simpledrm" ]; # Show splash earlier
    };
  };
}
