{ config, lib, ... }:
let
  cfg = config.my.home.lorri;
in
{
  options.my.home.lorri = with lib; {
    enable = (mkEnableOption "lorri daemon setup") // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    services.lorri.enable = true;
    programs.direnv = {
        enable = true;
        enableFishIntegration = true;
    };
  };
}
