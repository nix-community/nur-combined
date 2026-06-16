{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkPackageOption
    types
    mkIf
    ;

  cfg = config.swarselservices.attic-client;
in
{
  _class = "homeManager";

  options.swarselservices.attic-client = {
    enable = mkEnableOption ''
      the attic binary cache client with a declaratively managed configuration
    '';

    package = mkPackageOption pkgs "attic-client" { };

    defaultServer = mkOption {
      type = types.nullOr types.str;
      default =
        if lib.length (lib.attrNames cfg.servers) == 1 then lib.head (lib.attrNames cfg.servers) else null;
      defaultText = lib.literalExpression "the only configured server, or null when several are defined";
      description = ''
        Name of the server to use by default (rendered as `default-server` in
        the attic configuration). Must be a key in
        {option}`swarselservices.attic-client.servers`.
      '';
    };

    servers = mkOption {
      default = { };
      description = ''
        Attic servers to declare in the client configuration. Each entry is
        rendered as a `[servers.<name>]` section in `attic/config.toml`.

        The configuration file is rendered by a user service that reads each
        server's token from {option}`tokenFile` at runtime, keeping it out of
        the world-readable Nix store.
      '';
      example = lib.literalExpression ''
        {
          swarsel = {
            endpoint = "https://store.swarsel.win";
            tokenFile = "/run/secrets/attic-token";
          };
        }
      '';
      type = types.attrsOf (
        types.submodule {
          options = {
            endpoint = mkOption {
              type = types.str;
              description = ''
                Base API endpoint of the attic server, e.g.
                `https://store.swarsel.win`.
              '';
            };

            tokenFile = mkOption {
              type = types.str;
              description = ''
                Path to a file containing the access token. The file is read at
                runtime, so the token never enters the Nix store.

                This is a plain path string (e.g. a sops/agenix secret path under
                {file}`/run`); it is intentionally not typed as a Nix path so that
                runtime-only secret files are not copied into the store.
              '';
            };
          };
        }
      );
    };

    watchStore = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "swarsel:swarsel" ];
      description = ''
        Caches to continuously push new store paths to via `attic watch-store`,
        each in `server:cache` form (or just `cache` to use the default server).
        One user service is created per entry; leave empty to disable.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.defaultServer == null || cfg.servers ? ${cfg.defaultServer};
        message = "swarselservices.attic-client.defaultServer must reference a configured server in swarselservices.attic-client.servers.";
      }
    ];

    home.packages = [ cfg.package ];

    systemd.user.services =
      let
        atticConfigScript = pkgs.writeShellApplication {
          name = "attic-config";
          runtimeInputs = [ pkgs.coreutils ];
          text = ''
            configPath="${config.xdg.configHome}/attic/config.toml"
            install -d -m700 "$(dirname "$configPath")"
            stagingPath="$(mktemp "$(dirname "$configPath")/.config.toml.XXXXXX")"

            cleanup() {
              echo "Failed to render attic config." >&2
              rm -f "$stagingPath"
              exit 1
            }
            trap cleanup SIGINT

            chmod 600 "$stagingPath"
            ${lib.optionalString (cfg.defaultServer != null)
              ''printf 'default-server = "%s"\n' ${lib.escapeShellArg cfg.defaultServer} >> "$stagingPath"''}
            ${lib.concatStrings (
              lib.mapAttrsToList
                (name: server: ''
                  if [[ ! -r ${lib.escapeShellArg server.tokenFile} ]]; then
                    echo "attic token file ${server.tokenFile} not readable" >&2
                    cleanup
                  fi
                  {
                    printf '\n[servers.%s]\n' ${lib.escapeShellArg name}
                    printf 'endpoint = "%s"\n' ${lib.escapeShellArg server.endpoint}
                    printf 'token = "%s"\n' "$(cat ${lib.escapeShellArg server.tokenFile})"
                  } >> "$stagingPath"
                '')
                cfg.servers
            )}

            mv -f "$stagingPath" "$configPath"
          '';
        };
      in
      {
        attic-config = {
          Unit.Description = "Render the attic client configuration";
          Service = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = lib.getExe atticConfigScript;
            Restart = "on-abnormal";
          };
          Install.WantedBy = [ "default.target" ];
        };
      }
      // lib.optionalAttrs (cfg.watchStore != [ ]) (
        lib.listToAttrs (
          map
            (cache: lib.nameValuePair "attic-watch-store-${lib.replaceStrings [ ":" ] [ "-" ] cache}" {
              Unit = {
                Description = "Push new store paths to the attic cache ${cache}";
                Requires = [ "attic-config.service" "graphical-session.target" ];
                After = [ "attic-config.service" "graphical-session.target" ];
                PartOf = [ "graphical-session.target" ];
              };

              Install.WantedBy = [ "graphical-session.target" ];

              Service = {
                ExecStart = "${lib.getExe cfg.package} watch-store ${cache}";
                Restart = "always";
                RestartSec = 30;
              };
            })
            cfg.watchStore
        )
      );
  };
}
