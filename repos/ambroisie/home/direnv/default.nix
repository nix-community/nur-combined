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
    nix-direnv = {
      # A better `use_nix`
      enable = true;
      # And `use_flake`
      enableFlakes = true;
    };
  };
}
