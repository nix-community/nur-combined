{ localFlake, withSystem }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optional
    optionalAttrs
    types
    ;

  cfg = config.services.teamspeak6-server;
  settingsFormat = pkgs.formats.yaml { };

  generatedConfigFile = settingsFormat.generate "tsserver.yaml" cfg.settings;
  configFile = if cfg.settingsFile != null then cfg.settingsFile else generatedConfigFile;

  voicePort = cfg.defaultVoicePort;
  fileTransferPort = cfg.fileTransferPort;
in
{
  options.services.teamspeak6-server = {
    enable = mkEnableOption "TeamSpeak 6 voice communication server";

    package = mkOption {
      type = types.package;
      default = withSystem pkgs.stdenv.hostPlatform.system (
        { config, ... }: config.packages.teamspeak6-server
      );
      defaultText = lib.literalMD "`packages.teamspeak6-server` from the shirok1/flakes flake";
      description = "The TeamSpeak 6 server package to use.";
    };

    acceptLicense = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to accept the TeamSpeak server license agreement.

        This must be set to true for the service to start non-interactively.
      '';
    };

    settings = mkOption {
      type = settingsFormat.type;
      default = { };
      description = ''
        TeamSpeak server YAML configuration rendered to `tsserver.yaml`.

        This is ignored when `settingsFile` is set. Use attr names matching
        TeamSpeak's YAML format, for example `server.database.plugin`.
      '';
      example = {
        server = {
          query.ssh.enable = 0;
        };
      };
    };

    settingsFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to an existing TeamSpeak server YAML configuration file.

        If set, `settings` is ignored and this file is passed via
        `--config-file` unchanged.
      '';
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Optional environment file loaded by systemd for secrets or settings
        supported by TeamSpeak's `TSSERVER_*` environment variables.
      '';
      example = "/run/secrets/teamspeak6-server.env";
    };

    defaultVoicePort = mkOption {
      type = types.port;
      default = 9987;
      description = "Default UDP voice port for the first virtual server.";
    };

    voiceIp = mkOption {
      type = types.listOf types.str;
      default = [
        "0.0.0.0"
        "::"
      ];
      description = "IP addresses for the server to bind the voice port to.";
    };

    fileTransferPort = mkOption {
      type = types.port;
      default = 30033;
      description = "TCP port for file transfer connections.";
    };

    fileTransferIp = mkOption {
      type = types.listOf types.str;
      default = [
        "0.0.0.0"
        "::"
      ];
      description = "IP addresses for the server to bind the file transfer port to.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open the default voice UDP port and file-transfer TCP port
        in the firewall.
      '';
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional command-line arguments passed to `tsserver`.";
      example = [ "--no-default-virtual-server" ];
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.acceptLicense;
        message = "`services.teamspeak6-server.acceptLicense` must be true to run TeamSpeak 6 server.";
      }
    ];

    systemd.services.teamspeak6-server = {
      description = "TeamSpeak 6 Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      restartIfChanged = true;

      environment = {
        TSSERVER_CONFIG_FILE = toString configFile;
        TSSERVER_LICENSE_ACCEPTED = "1";
        TSSERVER_DEFAULT_PORT = toString voicePort;
        TSSERVER_VOICE_IP = lib.concatStringsSep "," cfg.voiceIp;
        TSSERVER_FILE_TRANSFER_PORT = toString fileTransferPort;
        TSSERVER_FILE_TRANSFER_IP = lib.concatStringsSep "," cfg.fileTransferIp;
        TSSERVER_LOG_PATH = "logs";
        TSSERVER_CRASHDUMP_PATH = "crashdumps";
      };

      serviceConfig = {
        ExecStart = lib.escapeShellArgs ([ (lib.getExe cfg.package) ] ++ cfg.extraArgs);
        EnvironmentFile = optional (cfg.environmentFile != null) cfg.environmentFile;
        Restart = "on-failure";
        DynamicUser = true;
        StateDirectory = "teamspeak6-server";
        WorkingDirectory = "/var/lib/teamspeak6-server";
        LimitNOFILE = 32768;
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedUDPPorts = [ voicePort ];
      allowedTCPPorts = [ fileTransferPort ];
    };

    environment.systemPackages = [ cfg.package ];
  };
}
