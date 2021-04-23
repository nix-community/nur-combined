{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.packages;
in
{
  options.my.home.packages = with lib.my; {
    enable = mkDisableOption "user packages";
  };

  config.home.packages = with pkgs; lib.mkIf cfg.enable [
    # Git related
    gitAndTools.git-absorb
    gitAndTools.git-revise
    gitAndTools.tig
    # Dev work
    rr
    # Terminal prettiness
    termite.terminfo
  ];
}
