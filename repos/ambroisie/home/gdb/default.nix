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

      # FIXME: waiting for commit 64aaad6349d2b2c45063a5383f877ce9a3a0c354
      xdg.configFile."gdb/gdbinit".source = ./gdbinit;

      # FIXME: remove once `gdb` is updated from version 10.2
      home.file.".gdbinit".source = ./gdbinit;
    })

    (lib.mkIf cfg.rr.enable {
      home.packages = [
        cfg.rr.package
      ];
    })
  ];
}
