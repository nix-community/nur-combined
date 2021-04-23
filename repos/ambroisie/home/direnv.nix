{ config, lib, ... }:
let
  cfg = config.my.home.direnv;
in
{
  options.my.home.direnv = with lib.my; {
    enable = mkDisableOption "direnv configuration";
  };

  config.programs.direnv = lib.mkIf cfg.enable {
    enable = true;
    # A better `use_nix`
    enableNixDirenvIntegration = true;
  };
}
