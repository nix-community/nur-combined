{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.gdb;
in
{
  options.my.home.gdb = with lib; {
    enable = my.mkDisableOption "gdb configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gdb
    ];

    xdg.configFile."gdb/gdbinit".source = ./gdbinit;
  };
}
