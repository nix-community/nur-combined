{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.instantlock;

in
{
  options = {
    programs.instantlock = {
      enable = mkOption {
        default = ture;
        type = types.bool;
        description = ''
          Whether to install instantlock screen locker with setuid wrapper.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.instantlock ];
    security.wrappers.instantlock.source = "${pkgs.instantlock.out}/bin/instantlock";
  };
}
