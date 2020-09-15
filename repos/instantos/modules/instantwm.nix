{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.instantwm;

in

{

  ###### interface

  options = {
    services.xserver.windowManager.instantwm.enable = mkEnableOption "instantwm";
  };


  ###### implementation

  config = mkIf cfg.enable {

    services.xserver.windowManager.session = singleton
      { name = "instantwm";
        start =
          ''
            startinstantos &
            waitPID=$!
          '';
      };
    config.programs.instantlock.enable = true;

    environment.systemPackages = [ pkgs.instantwm ];

  };

}
