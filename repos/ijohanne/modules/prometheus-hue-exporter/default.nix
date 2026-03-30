self:
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.prometheus-hue-exporter;
  package = self.legacyPackages.${pkgs.stdenv.hostPlatform.system}.prometheus-hue-exporter;

  instanceModule = { name, ... }: {
    options = {
      enable = mkEnableOption "the prometheus hue exporter instance";
      enableLocalScraping = mkEnableOption "scraping by local prometheus";
      port = mkOption {
        type = types.port;
        default = 9773;
        description = "Port to listen on.";
      };
      listenAddress = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Address to listen on.";
      };
      extraFlags = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Extra commandline options to pass to the hue exporter.";
      };
      hueUrl = mkOption {
        type = types.str;
        description = "URL or IP of the Hue bridge to monitor.";
      };
      hueApiKeyFile = mkOption {
        type = types.path;
        description = ''
          Path to a file containing the Hue API key.
          Create a user as described in the docs at https://developers.meethue.com/develop/get-started-2
        '';
      };
    };
  };

  enabledInstances = filterAttrs (_: inst: inst.enable) cfg;
in
{
  options.services.prometheus-hue-exporter = mkOption {
    type = types.attrsOf (types.submodule instanceModule);
    default = { };
  };

  config = mkIf (enabledInstances != { }) {
    users.users.hue-exporter = {
      description = "Prometheus hue exporter service user";
      isSystemUser = true;
      group = "hue-exporter";
    };
    users.groups.hue-exporter = { };

    systemd.services = mapAttrs' (instName: inst:
      nameValuePair "prometheus-hue-exporter-${instName}" (
        let
          wrapper = pkgs.writeShellScript "prometheus-hue-exporter-${instName}" ''
            exec ${getBin package}/bin/hue_exporter \
              ${concatStringsSep " " inst.extraFlags} \
              -listen-address "${inst.listenAddress}:${toString inst.port}" \
              -hue-url "${inst.hueUrl}" \
              -username "$(cat "$CREDENTIALS_DIRECTORY/hue-api-key")" \
              -metrics-file "${package}/share/hue_metrics.json"
          '';
        in
        {
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            Restart = "always";
            PrivateTmp = true;
            WorkingDirectory = "/tmp";
            DynamicUser = false;
            User = "hue-exporter";
            Group = "hue-exporter";
            ExecStart = toString wrapper;
            LoadCredential = [
              "hue-api-key:${inst.hueApiKeyFile}"
            ];
          };
        }
      )
    ) enabledInstances;

    services.prometheus.scrapeConfigs =
      let
        scrapedInstances = filterAttrs (_: inst: inst.enableLocalScraping) enabledInstances;
      in
      mapAttrsToList (instName: inst: {
        job_name = "hue-${instName}";
        honor_labels = true;
        static_configs = [{
          targets = [ "127.0.0.1:${toString inst.port}" ];
        }];
      }) scrapedInstances;
  };
}
