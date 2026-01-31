{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.snell-server;
  settingsFormat = pkgs.formats.ini { };
  iniAtom = settingsFormat.lib.types.atom;
  sectionType = lib.types.attrsOf iniAtom;
in
{
  options.services.snell-server = {
    enable = lib.mkEnableOption "Enable Snell Proxy Service";

    settings = lib.mkOption {
      type = lib.types.nullOr sectionType;
      default = null;
      description = "INI settings to write into the configuration file.";
      example = { };
    };

    settingsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Configuration file to be passed directly.
      '';
    };

    pskFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        File containing the PSK to inject into the generated configuration.

        This is only supported when using `settings` and cannot be used with
        `settingsFile` or `settings.psk`.
      '';
    };

    package = lib.options.mkPackageOption pkgs "snell-server" { };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          let
            noSettings = cfg.settings == null;
            noSettingsFile = cfg.settingsFile == null;
          in
          (noSettings && !noSettingsFile) || (!noSettings && noSettingsFile);
        message = "Option `settings` or `settingsFile` must be set and cannot be set simultaneously";
      }
      {
        assertion = cfg.pskFile == null || (cfg.settings != null && cfg.settingsFile == null);
        message = "Option `pskFile` requires `settings` and cannot be used with `settingsFile`.";
      }
      {
        assertion = cfg.pskFile == null || !(cfg.settings != null && cfg.settings ? psk);
        message = "Option `pskFile` cannot be used with `settings.psk`. Leave it unset.";
      }
    ];

    systemd.services.snell-server = {
      description = "Snell Proxy Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      restartIfChanged = true;

      serviceConfig = {
        ExecStart =
          if cfg.pskFile != null then
            let
              templateFile = settingsFormat.generate "snell-server-template.conf" {
                snell-server = lib.filterAttrs (name: _: name != "psk") cfg.settings;
              };
            in
            pkgs.writeShellScript "snell-server-wrapper" ''
              psk="$(tr -d "\n" < ${cfg.pskFile})"  
              exec ${lib.getExe cfg.package} -c <(cat ${templateFile} <(printf "\npsk = %s\n" "$psk"))
            ''
          else
            "${lib.getExe cfg.package} -c ${
              if cfg.settingsFile != null then
                cfg.settingsFile
              else
                settingsFormat.generate "snell-server.conf" {
                  snell-server = cfg.settings;
                }
            }";
        Restart = "on-failure";
        DynamicUser = true;
        LimitNOFILE = 32768;
      };
    };

    environment = {
      systemPackages = [ cfg.package ];
    };
  };
}
