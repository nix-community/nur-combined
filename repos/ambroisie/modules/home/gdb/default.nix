{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.gdb;
in
{
  options.my.home.gdb = with lib; {
    enable = my.mkDisableOption "gdb configuration";

    package = mkPackageOption pkgs "gdb" { };

    rr = {
      enable = my.mkDisableOption "rr configuration";

      package = mkPackageOption pkgs "rr" { };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = with pkgs; [
        cfg.package
      ];

      xdg = {
        configFile."gdb/gdbinit".source = ./gdbinit;
        stateFile."gdb/.keep".text = "";
      };

      home.sessionVariables = {
        GDBHISTFILE = "${config.xdg.stateHome}/gdb/gdb_history";
      };
    }

    (lib.mkIf cfg.rr.enable {
      home.packages = [
        cfg.rr.package
      ];
    })
  ]);
}
