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
    mkMerge
    mkOption
    mkPackageOption
    nameValuePair
    optionalAttrs
    optionalString
    ;

  types = lib.types;
  format = pkgs.formats.json { };

  commonOptions =
    {
      pkgName,
      flavour ? pkgName,
    }:
    mkOption {
      default = { };
      description = ''
        Attribute set of ${flavour} instances.

        Creates independent `${flavour}-''${name}` launchd daemons for each
        instance defined here.
      '';
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              enable = mkEnableOption "this ${flavour} instance" // {
                default = true;
              };

              package = mkPackageOption pkgs pkgName { };

              debug = lib.mkEnableOption "verbose log";

              user = mkOption {
                type = types.str;
                default = "root";
                description = ''
                  User under which this instance runs.
                '';
              };

              group = mkOption {
                type = types.str;
                default = "admin";
                description = ''
                  Group under which this instance runs.
                '';
              };

              settings = mkOption {
                type = types.submodule {
                  freeformType = format.type;

                  options = {
                    pid_file = mkOption {
                      default = "/run/${flavour}/${name}.pid";
                      type = types.str;
                      description = ''
                        Path to use for the pid file.
                      '';
                    };
                  };
                };

                default = { };

                description =
                  let
                    upstreamDocs =
                      if flavour == "vault-agent" then
                        "https://developer.hashicorp.com/vault/docs/agent#configuration-file-options"
                      else
                        "https://github.com/hashicorp/consul-template/blob/main/docs/configuration.md#configuration-file";
                  in
                  ''
                    Free-form settings written directly to the {file}`config.json` file.
                    Refer to <${upstreamDocs}> for supported values.

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

  createDaemon =
    {
      name,
      flavour,
      instance,
    }:
    let
      configFile = format.generate "${flavour}-${name}.json" instance.settings;
      pidDir = dirOf instance.settings.pid_file;
    in
    {
      script = ''
        mkdir -p ${lib.escapeShellArg pidDir}
        chown ${lib.escapeShellArg "${instance.user}:${instance.group}"} ${lib.escapeShellArg pidDir}
        exec ${lib.getExe instance.package}${
          optionalString (flavour == "vault-agent") " agent"
        } -config=${configFile}${optionalString instance.debug " -log-level=debug"}
      '';

      serviceConfig = {
        Label = "org.nixos.${flavour}-${name}";

        UserName = instance.user;
        GroupName = instance.group;

        RunAtLoad = true;
        KeepAlive = true;

        # Rough equivalent to the old systemd start-limit throttling.
        ThrottleInterval = 60;

        # Rough equivalent to TimeoutStopSec = "30s".
        ExitTimeOut = 30;
      }
      // optionalAttrs instance.debug {
        StandardOutPath = "/Library/Logs/${flavour}/${name}/stdout";
        StandardErrorPath = "/Library/Logs/${flavour}/${name}/stderr";
      };
    };
in
{
  options = {
    services.consul-template.instances = commonOptions {
      pkgName = "consul-template";
    };

    services.vault-agent.instances = commonOptions {
      pkgName = "vault";
      flavour = "vault-agent";
    };
  };

  config = mkMerge (
    map
      (
        flavour:
        let
          cfg = config.services.${flavour};
          enabledInstances = filterAttrs (_: instance: instance.enable) cfg.instances;
        in
        mkIf (enabledInstances != { }) {
          launchd.daemons = mapAttrs' (
            name: instance:
            nameValuePair "${flavour}-${name}" (createDaemon {
              inherit name flavour instance;
            })
          ) enabledInstances;
        }
      )
      [
        "consul-template"
        "vault-agent"
      ]
  );

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
