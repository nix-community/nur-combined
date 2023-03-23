imports: { config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.gaming;
in {
  inherit imports;

  options.programs.gaming = {
    enable = mkEnableOption ''
      Stuff for gaming
    '';
  };

  config = mkIf cfg.enable {
    programs.gamescope.enable = true;
    environment.systemPackages = with pkgs; [ mangohud ];
  };
}
