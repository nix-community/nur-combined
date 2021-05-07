{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.packages;
in
{
  options.my.home.packages = with lib; {
    enable = my.mkDisableOption "user packages";

    additionalPackages = mkOption {
      type = with types; listOf package;
      default = [ ];
      example = literalExample ''
        with pkgs; [
          quasselClient
        ]
      '';
    };
  };

  config.home.packages = with pkgs; lib.mkIf cfg.enable ([
    # Git related
    gitAndTools.git-absorb
    gitAndTools.git-revise
    gitAndTools.tig
    # Dev work
    rr
    # Terminal prettiness
    termite.terminfo
  ] ++ cfg.additionalPackages);
}
