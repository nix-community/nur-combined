{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    filterAttrs
    mapAttrs'
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    nameValuePair
    ;

  types = lib.types;
  format = pkgs.formats.json { };

  cfg = config.services.vault-agent;

  enabledInstances = filterAttrs (_: instance: instance.enable) cfg.instances;

  createVaultAgentDaemon =
    name: instance:
    let
      configFile = format.generate "vault-agent-${name}.json" instance.settings;
    in
    {
      serviceConfig = {
        Label = "org.nixos.vault-agent-${name}";

        script = ''
          mkdir -p ${lib.escapeShellArg (dirOf instance.settings.pid_file)}
          chown ${lib.escapeShellArg "${instance.user}:${instance.group}"} ${lib.escapeShellArg (dirOf instance.settings.pid_file)}
          exec ${lib.getExe instance.package} agent -config ${configFile}
        '';

        UserName = instance.user;
        GroupName = instance.group;

        RunAtLoad = true;
        KeepAlive = true;

        # Rough equivalent to the old systemd start-limit throttling.
        ThrottleInterval = 60;

        # Rough equivalent to TimeoutStopSec = "30s".
        ExitTimeOut = 30;
      };
    };
in
{
  options.services.vault-agent.instances = mkOption {
    default = { };
    description = ''
      Attribute set of vault-agent instances.

      Creates independent `vault-agent-''${name}` launchd daemons for each
      instance defined here.
    '';
    type = types.attrsOf (
      types.submodule (
        { name, ... }:
        {
          options = {
            enable = mkEnableOption "this vault-agent instance" // {
              default = true;
            };

            package = mkPackageOption pkgs "vault" { };

            user = mkOption {
              type = types.str;
              default = "root";
              description = ''
                User under which this instance runs.
              '';
            };

            group = mkOption {
              type = types.str;
              default = "wheel";
              description = ''
                Group under which this instance runs.
              '';
            };

            settings = mkOption {
              type = types.submodule {
                freeformType = format.type;

                options = {
                  pid_file = mkOption {
                    default = "/run/vault-agent/${name}.pid";
                    type = types.str;
                    description = ''
                      Path to use for the pid file.
                    '';
                  };
                };
              };

              default = { };

              description = ''
                Free-form settings written directly to the {file}`config.json` file.
                Refer to <https://developer.hashicorp.com/vault/docs/agent#configuration-file-options>
                for supported values.

                ::: {.note}
                Resulting format is JSON not HCL.
                Refer to <https://www.hcl2json.com/> if you are unsure how to
                convert HCL options to JSON.
                :::
              '';
            };
          };
        }
      )
    );
  };

  config = mkIf (enabledInstances != { }) {
    launchd.daemons = mapAttrs' (
      name: instance: nameValuePair "vault-agent-${name}" (createVaultAgentDaemon name instance)
    ) enabledInstances;
  };

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
