{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;

  cfg = config.swarselprograms.attic-client;
in
{
  _class = "homeManager";

  options.swarselprograms.attic-client = {
    enable = lib.mkEnableOption "the attic binary cache client";

    package = lib.mkPackageOption pkgs "attic-client" { };

    defaultServer = mkOption {
      type = types.nullOr types.str;
      default =
        let
          servers = lib.attrNames cfg.servers;
        in
        if lib.length servers == 1 then lib.head servers else null;
      defaultText = "The only configured server, or null";
      description = "Name of the server to use by default.";
    };

    servers = mkOption {
      default = { };
      description = "Attic servers to configure.";
      example = lib.literalExpression ''
        {
          mycache = {
            endpoint = "https://mycacheserver.org";
            tokenFile = "/run/secrets/mycacheserver-attic-token";
          };
        }
      '';
      type = types.attrsOf (
        types.submodule {
          options = {
            endpoint = mkOption {
              type = types.str;
              description = "Endpoint of the attic server.";
            };

            tokenFile = mkOption {
              type = types.str;
              description = "Path to a file containing the server access token.";
            };
          };
        }
      );
    };

    watchStore = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "mycacheserver:mycache" ];
      description = ''
        Caches to push new store paths to via `attic watch-store`.
        Format: `server:cache` (or just `cache` to use the default server).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.defaultServer == null || cfg.servers ? ${cfg.defaultServer};
        message = "swarselprograms.attic-client.defaultServer must reference a configured server in swarselprograms.attic-client.servers.";
      }
    ];

    home.packages = [ cfg.package ];

    systemd.user.services =
      let
        atticConfigScript = pkgs.writeShellApplication {
          name = "attic-config";
          runtimeInputs = [ pkgs.coreutils ];
          text = ''
            configDir="${config.xdg.configHome}/attic"
            configPath="$configDir/config.toml"
            install -d -m700 "$configDir"
            stagingPath="$(mktemp "$configDir/.config.toml.XXXXXX")"
            trap 'rm -f "$stagingPath"' EXIT

            ${lib.optionalString (
              cfg.defaultServer != null
            ) ''printf 'default-server = "%s"\n' ${lib.escapeShellArg cfg.defaultServer} >> "$stagingPath"''}
            ${lib.concatStrings (
              lib.mapAttrsToList (name: server: ''
                if [[ ! -r ${lib.escapeShellArg server.tokenFile} ]]; then
                  echo "attic token file ${server.tokenFile} not readable" >&2
                  exit 1
                fi
                {
                  printf '[servers.%s]\n' ${lib.escapeShellArg name}
                  printf 'endpoint = "%s"\n' ${lib.escapeShellArg server.endpoint}
                  printf 'token = "%s"\n' "$(cat ${lib.escapeShellArg server.tokenFile})"
                } >> "$stagingPath"
              '') cfg.servers
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
          };
          Install.WantedBy = [ "default.target" ];
        };
      }
      // lib.optionalAttrs (cfg.watchStore != [ ]) (
        lib.listToAttrs (
          map (
            cache:
            lib.nameValuePair "attic-watch-store--${lib.replaceStrings [ ":" ] [ "-" ] cache}" {
              Unit = {
                Description = "Push new store paths to the attic cache ${cache}";
                Requires = [ "attic-config.service" ];
                After = [ "attic-config.service" ];
              };

              Install.WantedBy = [ "default.target" ];

              Service = {
                ExecStart = "${lib.getExe cfg.package} watch-store ${cache}";
                Restart = "always";
                RestartSec = 30;
              };
            }
          ) cfg.watchStore
        )
      );
  };

}
