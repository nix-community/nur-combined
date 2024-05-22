{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.btop;
in

{
  options.abszero.programs.btop.enable = mkEnableOption "system resources monitor";

  config.programs.btop = mkIf cfg.enable {
    enable = true;
    settings = {
      proc_sorting = "memory";
      io_mode = true;
      show_battery = false;
    };
  };
}
