{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.prometheus-podman-exporter;
  settingsFormat = pkgs.formats.yaml { };
in
{
  options.services.prometheus-podman-exporter = {
    enable = mkEnableOption (mdDoc "Prometheus exporter for podman (v4) machine");
    package = lib.mkPackageOption pkgs "prometheus-podman-exporter" { };
    cmdFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = lib.mdDoc "A list of flags for 'prometheus-podman-exporter'.";
      example = [ "--collector.enable-all" ];
    };
    webSettings = mkOption {
      type = settingsFormat.type;
      default = { };
      description = lib.mdDoc ''
        Web Configuration.
        Refer to <https://github.com/prometheus/exporter-toolkit/blob/master/docs/web-configuration.md>
        for details on supported values.
      '';
    };
  };
  config = mkIf cfg.enable {
    virtualisation.podman.enable = true;
    virtualisation.containers.containersConf.settings = {
      engine.helper_binaries_dir = [ "${config.virtualisation.podman.package}/libexec/podman" ];
    };

    systemd.services.prometheus-podman-exporter = {
      description = "Prometheus exporter for podman (v4) machine";
      wantedBy = [ "multi-user.target" ];
      wants = [ "podman.socket" ];
      after = [ "podman.socket" ];
      path = with pkgs; [
        cfg.package
        procps
        runc
        crun
        conmon
        # Potentially needed, but i don't know how to test it
        fuse-overlayfs
      ];
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        ExecStart = pkgs.writeShellScript "prometheus-podman-exporter-start" "prometheus-podman-exporter ${concatStringsSep " " cfg.cmdFlags} ${
          optionalString (cfg.webSettings != { })
            "--web.config.file ${settingsFormat.generate "webconfig.yaml" cfg.webSettings}"
        }";
        ExecReload = pkgs.writeShellScript "prometheus-podman-exporter-reload" "kill -HUP $MAINPID";
        TimeoutStopSec = "20s";
        SendSIGKILL = "no";
      };
    };
  };
}
