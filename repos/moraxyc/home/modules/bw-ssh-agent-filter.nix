{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;

  cfg = config.services.bw-ssh-agent-filter;

  name = "bw-ssh-agent-filter";
  bin = lib.getExe cfg.package;

  args = [
    "-listen=${cfg.listen}"
    "-upstream=${cfg.upstream}"
    "-keys=${keysFile}"
  ];
  keysFile =
    if cfg.configFile != null then
      cfg.configFile
    else
      pkgs.writeText "bw-ssh-agent-filter-config" cfg.config;
in
{
  options.services.bw-ssh-agent-filter = {
    enable = lib.mkEnableOption "bw-ssh-agent-filter service";

    package = lib.mkPackageOption pkgs name { };

    config = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Configuration for the bw-ssh-agent-filter service.";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to the configuration file.";
    };

    upstream = lib.mkOption {
      type = lib.types.str;
      description = "The upstream SSH agent socket to connect to.";
    };

    listen = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.ssh/bw-agent-proxy.sock";
      defaultText = lib.literalExpression "\${config.home.homeDirectory}/.ssh/bw-agent-proxy.sock";
      description = "The socket path where bw-ssh-agent-filter will listen for SSH agent connections.";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf (isLinux && cfg.enable) {
      systemd.user.services.${name} = {
        Service = {
          ExecStartPre = "${lib.getExe' pkgs.coreutils "rm"} -f ${lib.escapeShellArg cfg.listen}";
          ExecStart = lib.escapeShellArgs ([ bin ] ++ args);
          Restart = "on-failure";
        };

        Install.WantedBy = [ "default.target" ];
      };
    })

    (lib.mkIf (isDarwin && cfg.enable) {
      launchd.agents.${name} = {
        enable = true;
        config =
          let
            script = pkgs.writeShellScript "${name}-launcher" ''
              rm -f ${lib.escapeShellArg cfg.listen}
              exec ${lib.escapeShellArgs ([ bin ] ++ args)}
            '';
          in
          {
            ProgramArguments = [ (toString script) ];
            RunAtLoad = true;
            KeepAlive = true;
            StandardOutPath = "${config.home.homeDirectory}/Library/Logs/${name}.stdout.log";
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/${name}.stderr.log";
          };
      };
    })
  ];
}
