{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.fungi;
  mylib = import ../../lib { inherit pkgs; };
  myCallPackage = pkgs.newScope (pkgs // mylib);
  defaultPackage = myCallPackage ../../pkgs/fungi { };
in
{
  options.services.fungi = {
    enable = lib.mkEnableOption "fungi service";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      description = "The fungi package to use.";
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the config.toml file.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.fungi = { };
    users.users.fungi = {
      isSystemUser = true;
      group = "fungi";
      home = "/var/lib/fungi";
      description = "Fungi service user";
    };

    systemd.services.fungi = {
      description = "fungi service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = "fungi";
        Group = "fungi";

        StateDirectory = "fungi";
        WorkingDirectory = "%S/fungi";

        Environment = [
          "HOME=/var/lib/fungi"
          "RUST_BACKTRACE=1"
        ];

        Restart = "on-failure";
        RestartSec = "60s";

        ExecStartPre =
          let
            initScript = pkgs.writeShellScript "fungi-init-script" ''
              set -e

              TARGET_DIR="$STATE_DIRECTORY"

              # 重复 init 会报错，忽略此报错
              ${cfg.package}/bin/fungi --fungi-dir "$TARGET_DIR" init || true

              ${pkgs.coreutils}/bin/install -m 640 ${cfg.configFile} "$TARGET_DIR/config.toml"
            '';
          in
          [ "${initScript}" ];

        # 在 ExecStart 中直接引用环境变量 $STATE_DIRECTORY
        ExecStart = ''
          ${cfg.package}/bin/fungi --fungi-dir $STATE_DIRECTORY daemon
        '';
      };
    };
  };
}
