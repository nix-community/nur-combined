{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rindex;
in
{
  options.services.rindex = {
    enable = lib.mkEnableOption "rindex";
    package = lib.mkPackageOption pkgs "rindex" { };
    settings = {
      directory = lib.mkOption {
        type = lib.types.path;
      };
      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 3500;
      };
      logdir = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
      };
      verbose = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.rindex = {
      serviceConfig = {
        Type = "exec";
        ExecStart =
          let
            rindex = lib.getExe cfg.package;
            optionFormat = optionName: {
              option = "--${optionName}";
              sep = " ";
              explicitBool = false;
            };
            args = lib.cli.toCommandLineShell optionFormat cfg.settings;
          in
          "${rindex} ${args}";
      };
    };
  };
}
