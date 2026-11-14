{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.hydro-judge;
  format = pkgs.formats.yaml_1_2 { };
in
{
  options.services.hydro-judge = {
    enable = lib.mkEnableOption "Hydro judge";
    package = lib.mkPackageOption pkgs "hydro" { };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = format.type;
        options = {
          cache_dir = lib.mkOption {
            type = lib.types.str;
            default = "/var/cache/hydro-judge";
            description = "Cache directory.";
          };
        };
      };
      default = { };
      description = ''
        Judge configuration, see <https://hydro.js.org/en/docs/Hydro/plugins/hydrojudge> and <https://github.com/hydro-dev/Hydro/blob/master/packages/hydrojudge/src/config.ts> for documentation.

        Options containing secret data should be set to an attribute set containing the attribute `_secret` - a string pointing to a file containing the value the option should be set to.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.hydro-sandbox.enable = true;

    systemd.services.hydro-judge = {
      after = [
        "network.target"
        "hydro-sandbox.service"
      ];
      requires = [ "hydro-sandbox.service" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        CONFIG_FILE = "/run/hydro-judge/judge.yaml";
      };

      serviceConfig = {
        User = "hydro-judge";
        Group = "hydro-judge";
        DynamicUser = true;

        CacheDirectory = lib.mkIf (cfg.settings.cache_dir == "/var/cache/hydro-judge") "hydro-judge";

        RuntimeDirectory = "hydro-judge";
        RuntimeDirectoryMode = "0700";

        ExecStartPre =
          let
            script = pkgs.writeShellScript "hydro-judge-pre-start" ''
              ${utils.genJqSecretsReplacementSnippet cfg.settings "/run/hydro-judge/judge.json"}
              ${lib.getExe' pkgs.remarshal "json2yaml"} /run/hydro-judge/judge.json /run/hydro-judge/judge.yaml
              rm /run/hydro-judge/judge.json
              chown --reference=/run/hydro-judge /run/hydro-judge/judge.yaml
            '';
          in
          "+${script}";
        ExecStart = "${lib.getExe' cfg.package "hydrojudge"}";
      };
    };
  };
}
