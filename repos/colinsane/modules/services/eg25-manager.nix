# eg25-manager: <https://gitlab.com/mobian1/eg25-manager>
# - requires modemmanager (ModemManager.service)
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.services.eg25-manager;
  eg25-config-toml = pkgs.writeText "eg25-manager-config.toml" ''
    # config here is applied *on top of* the per-device configs shipped by eg25-manager.
    # these values take precedence, but there's no need to redefine things if we don't want them changed
    [at]
    uart = "/dev/ttyUSB2"
  '';
in
{
  options.sane.services.eg25-manager = with lib; {
    enable = mkEnableOption "Quectel EG25 modem manager service";
    package = mkPackageOption pkgs "eg25-manager" {};
  };
  config = lib.mkIf cfg.enable {
    # eg25-manager package ships udev rules *and* a systemd service.
    # for that reason, i think it needs to be on the system path for the systemd service to be enabled.
    services.udev.packages = [ cfg.package ];

    # but actually, let's define our own systemd service so that we can control config
    systemd.services.eg25-manager = {
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} --config ${eg25-config-toml}";
        ExecStartPre = pkgs.writeShellScript "unload-modem-power" ''
          # see issue: <https://gitlab.com/mobian1/eg25-manager/-/issues/38>
          ${lib.getExe' pkgs.kmod "modprobe"} -r modem_power && echo "WARNING: kernel configured with CONFIG_MODEM_POWER=y, may be incompatible with eg25-manager" || true
        '';

        Restart = "on-failure";
        RestartSec = "60s";  # can make this more frequent once stable?

        # sandboxing (taken from the service file shipped by eg25-manager):
        # TODO: this is too strict and breaks access to e.g. /dev/ttyUSB2!
        # ProtectControlGroups = true;
        # ProtectHome = true;
        # ProtectSystem = "strict";
        # RestrictSUIDSGID = true;
        # PrivateTmp = true;
        # MemoryDenyWriteExecute = true;
        # PrivateMounts = true;
        # NoNewPrivileges = true;
        # CapabilityBoundingSet = [ "" ];
        # LockPersonality = true;
      };
      before = [ "ModemManager.service" ];
      wantedBy = [ "multi-user.target" ];
    };

    # systemd.packages = [ pkgs.eg25-manager ];
    # systemd.services.eg25-manager.wantedBy = [ "multi-user.target" ];
    # systemd.services.prepare-eg25-manager = {
    #   description = "unload megi's modem_power module to provide gpio access to eg25-manager";
    #   serviceConfig.Type = "oneshot";
    #   wantedBy = [ "eg25-manager.service" ];
    #   before = [ "eg25-manager.service" ];
    #   script = ''
    #     ${lib.getExe' pkgs.kmod "modprobe"} -r modem_power && echo "WARNING: kernel configured with CONFIG_MODEM_POWER=y, may be incompatible with eg25-manager" || true
    #   '';
    # };
  };
}
