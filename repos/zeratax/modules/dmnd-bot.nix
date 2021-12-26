{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.dmnd-bot;
  format = pkgs.formats.yaml { };

  dmnd-bot-config =
    format.generate "config.yaml" cfg.settings;
  dmnd-bot-cli-wrapper = pkgs.stdenv.mkDerivation {
    name = "dmnd-bot-cli-wrapper";
    buildInputs = [ pkgs.makeWrapper ];
    buildCommand = ''
      mkdir -p $out/bin
      makeWrapper ${pkgs.dmnd-bot}/bin/dmnd_bot "$out/bin/dmnd_bot" \
        --add-flags "--config-path='${dmnd-bot-config}'"
    '';
  };

  serviceDependencies = optional config.services.syncplay.enable "syncplay.service";

  instanceOptions = {
    host = mkOption {
      type = types.str;
      example = "https://syncplay.pl:8995";
      description = "syncplay server address";
    };
    room = mkOption {
      type = types.str;
      example = "example";
      description = "room to join";
    };
    name = mkOption {
      type = types.str;
      example = "syncbot";
      description = "name to join room as";
    };
    password = mkOption {
      type = types.str;
      example = "pa$$w0rd";
      description = "syncplay server password";
      default = "";
    };
  };
in
{
  options.services.dmnd-bot = {
    enable = mkEnableOption "dmnd-bot";

    settings = mkOption {
      default = { };
      description = "dmnd-bot configuration.";
      type = types.submodule {
        freeformType = format.type;

        options = {
          discord = {
            id = mkOption {
              type = types.ints.positive;
              description = "your discord applications client_id, see https://discord.com/developers/";
              example = 921126401232841096;
            };
            token = mkOption {
              type = types.str;
              description = "your discord bot token, see https://discord.com/developers/";
              example = "OTIyNDk1XZYyODI4ODQ3MTI0.YcCS4w.BULT6nKADdWI9rxc5EJjKLJqBvg";
            };
          };
          saucenao = {
            enabled = mkOption {
              type = types.bool;
              default = false;
              description ="enable saucenao plugin";
            };
            token = mkOption {
              type = types.str;
              description = "your saucenao api token";
              example = "0ba0bbf77e391bdc1242e1e93f3d5a149d13a1c0";
            };
          };
          syncplay = {
            enabled = mkOption {
              type = types.bool;
              default = false;
              description ="enable syncplay plugin";
            };
            instaces = mkOption {
              type = types.listOf (types.submodule instanceOptions);
              default = [];
              description = "syncplay bot instances you want to run";
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.dmnd-bot = {
      description =
        "dmnd-bot, dmnd's official discord bot.";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ] ++ serviceDependencies;
      after = [ "network-online.target" ] ++ serviceDependencies;

      serviceConfig = {
        Type = "simple";
        Restart = "always";

        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;

        DynamicUser = true;
        PrivateTmp = true;
        UMask = 27;

        ExecStart = ''
          ${pkgs.dmnd-bot}/bin/dmnd_bot \
            --file="${dmnd-bot-config}"
        '';
      };
    };

    environment.systemPackages = [ dmnd-bot-cli-wrapper ];
  };

  # meta.maintainers = with maintainers; [ zeratax ];
}
