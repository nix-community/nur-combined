{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.gdb;
in
{
  options.my.home.gdb = with lib; {
    enable = my.mkDisableOption "gdb configuration";

    rr = {
      enable = my.mkDisableOption "rr configuration";

      package = mkOption {
        type = types.package;
        default = pkgs.rr;
        defaultText = literalExample "pkgs.rr";
        description = ''
          Package providing rr
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = with pkgs; [
        gdb
      ];

      xdg = {
        configFile."gdb/gdbinit".source = ./gdbinit;
        dataFile. "gdb/.keep".text = "";
      };

      home.sessionVariables = {
        GDBHISTFILE = "${config.xdg.dataHome}/gdb/gdb_history";
      };
    }

    (lib.mkIf cfg.rr.enable {
      home.packages = [
        cfg.rr.package
      ];
    })
  ]);
}
