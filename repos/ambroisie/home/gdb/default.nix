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

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        gdb
      ];

      xdg.configFile."gdb/gdbinit".source = ./gdbinit;
    })

    (lib.mkIf cfg.rr.enable {
      home.packages = [
        cfg.rr.package
      ];
    })
  ];
}
