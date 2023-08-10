# eg25-manager: <https://gitlab.com/mobian1/eg25-manager>
# - used by sxmo, in <configs/default_hooks/sxmo_hook_restart_modem_daemons.sh>
# - requires modemmanager (ModemManager.service)
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.services.eg25-manager;
in
{
  options.sane.services.eg25-manager = {
    enable = lib.mkEnableOption "Quectel EG25 modem manager service";
  };
  config = lib.mkIf cfg.enable {
    # eg25-manager package ships udev rules *and* a systemd service.
    # for that reason, i think it needs to be on the system path for the systemd service to be enabled.
    systemd.packages = [ pkgs.eg25-manager ];
    services.udev.packages = [ pkgs.eg25-manager ];
    systemd.services.eg25-manager.wantedBy = [ "multi-user.target" ];
  };
}
