{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.ams;
in
{
  ##### interface
  options = {
    services.ams = {
      enable = mkEnableOption "HPE Agentless Management Service";
    };
  };


  ##### implementation
  config = mkIf cfg.enable {
    # Provides
    # - ahslog.service
    # - amsd_rev.service
    # - amsd.service
    # - cpqFca_rev.service
    # - cpqFca.service
    # - cpqIde_rev.service
    # - cpqIde.service
    # - cpqiScsi.service
    # - cpqScsi.service
    # - mr_cpqScsi.service
    # - smad_rev.service
    # - smad.service
    #
    # - 81-cpqFca.rules
    # - 81-cpqiScsi.rules
    systemd.packages = [ pkgs.ams ];
    systemd.services.amsd.wantedBy = [ "multi-user.target" ];
    systemd.services.smad.wantedBy = [ "multi-user.target" ];
  };
}
