{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.koboldcpp;
in {
  options.programs.koboldcpp = {
    enable = mkEnableOption "koboldcpp";
    config = mkOption {
      type = types.str;
      default = "%h/.config/koboldcpp.kcpps";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ koboldcpp ];
    systemd.user.services.koboldcpp = {
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${getExe pkgs.koboldcpp} --config ${cfg.config}";
      };
    };
  };
}
