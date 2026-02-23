{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ollama;
  primaryUser = config.users.users.${config.system.primaryUser};
in
{
  options = {
    services.ollama = {
      enable = lib.mkEnableOption "Whether to enable the Ollama Daemon.";
      package = lib.mkPackageOption pkgs "ollama" { };
      home = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/ollama";
        example = "/home/foo";
        description = ''
          The home directory that the ollama service is started in.
        '';
      };
      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        example = "[::]";
        description = ''
          The host address which the ollama server HTTP interface listens to.
        '';
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 11434;
        example = 11111;
        description = ''
          Which port the ollama server listens to.
        '';
      };
      models = lib.mkOption {
        type = lib.types.str;
        default = "${cfg.home}/models";
        defaultText = "\${config.services.ollama.home}/models";
        example = "/path/to/ollama/models";
        description = ''
          The directory that the ollama service will read models from and download new models to.
        '';
      };
      environmentVariables = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        example = {
          OLLAMA_LLM_LIBRARY = "cpu";
          HIP_VISIBLE_DEVICES = "0,1";
        };
        description = ''
          Set arbitrary environment variables for the ollama service.

          Be aware that these are only seen by the ollama server (launchd daemon),
          not normal invocations like `ollama run`.
          Since `ollama run` is mostly a shell around the ollama server, this is usually sufficient.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    launchd.daemons.ollama = {
      serviceConfig = {
        Label = "ollama";
        StandardOutPath = "${primaryUser.home}/.ollama/launchd.stdout.log";
        StandardErrorPath = "${primaryUser.home}/.ollama/launchd.stderr.log";
        EnvironmentVariables = cfg.environmentVariables // {
          HOME = cfg.home;
          OLLAMA_MODELS = cfg.models;
          OLLAMA_HOST = "${cfg.host}:${toString cfg.port}";
          OLLAMA_DEBUG = "1";
          OLLAMA_CONTEXT_LENGTH = "32000";
          OLLAMA_FLASH_ATTENTION = "1";
          OLLAMA_KEEP_ALIVE = "24h";
        };
        ProgramArguments = [
          "${lib.getExe cfg.package}"
          "serve"
        ];
        UserName = config.system.primaryUser;
        GroupName = "staff";
        ExitTimeOut = 30;
        Disabled = false;
        KeepAlive = true;
      };
    };
  };
}
