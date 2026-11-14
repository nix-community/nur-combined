{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hydro-sandbox;
  format = pkgs.formats.yaml_1_2 { };
in
{
  options.services.hydro-sandbox = {
    enable = lib.mkEnableOption "Hydro sandbox";
    package = lib.mkPackageOption pkgs "go-judge" { };

    packages = lib.mkOption {
      type = lib.types.path;
      default = pkgs.buildEnv {
        name = "hydro-sandbox-env";
        paths = [
          pkgs.bash
          pkgs.coreutils
          pkgs.diffutils
          pkgs.gawk
          pkgs.gcc
        ];
        pathsToLink = [ "/bin" ];
      };
      description = ''
        Packages to use in the sandbox.  The closure will be mounted read-only.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = format.type;
      };
      default = { };
      description = ''
        Mount configuration, see <https://docs.goj.ac/mount> for documentation.
        Store closure mounts are appended at startup.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.hydro-sandbox.settings = {
      mount = [
        {
          type = "bind";
          source = "${cfg.packages}/bin";
          target = "/bin";
          readonly = true;
        }
        {
          type = "bind";
          source = "${cfg.packages}/bin";
          target = "/usr/bin";
          readonly = true;
        }
        {
          type = "bind";
          source = "/dev/null";
          target = "/dev/null";
        }
        {
          type = "tmpfs";
          target = "/w";
          data = "size=512m,nr_inodes=8k";
        }
        {
          type = "tmpfs";
          target = "/tmp";
          data = "size=512m,nr_inodes=8k";
        }
      ];
      proc = true;
      workDir = "/w";
    };

    systemd.services.hydro-sandbox = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        ES_MOUNT_CONF = "/run/hydro-sandbox/mount.yaml";
      };

      preStart =
        let
          json = pkgs.formats.json { };
          configFile = json.generate "hydro-sandbox-mount.json" cfg.settings;
          closureInfo = pkgs.closureInfo { rootPaths = [ cfg.packages ]; };
        in
        ''
          ${lib.getExe pkgs.jq} --rawfile storePaths ${closureInfo}/store-paths \
            '.mount += ($storePaths | split("\n") | map(select(length > 0) | {
              type: "bind", source: ., target: ., readonly: true
            }))' ${configFile} > /run/hydro-sandbox/mount.json
          ${lib.getExe' pkgs.remarshal "json2yaml"} /run/hydro-sandbox/mount.json /run/hydro-sandbox/mount.yaml
          rm /run/hydro-sandbox/mount.json
        '';

      serviceConfig = {
        RuntimeDirectory = "hydro-sandbox";

        ExecStart = "${lib.getExe cfg.package}";
      };
    };
  };
}
