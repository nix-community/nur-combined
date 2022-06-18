{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.archisteamfarm;
in {
  options.programs.archisteamfarm = {
    enable = mkEnableOption "ArchiSteamFarm instance configured for me";
  };

  config = mkIf cfg.enable {
    services.archisteamfarm.enable = true;
    services.archisteamfarm.web-ui.enable = true;
    systemd.services.asf.wantedBy = mkForce [ ];
    services.archisteamfarm.settings = {
      SteamOwnerID = "76561198025431624";
    };
    services.archisteamfarm.ipcSettings = {
      Kestrel = {
        Endpoints = {
          HTTP = {
            Url = "http://*:1242";
          };
        };
        KnownNetworks = [
          "0.0.0.0/0"
        ];
      };
    };
    services.archisteamfarm.bots = {
      dukzcry = {
        passwordFile = "/dev/null";
        settings = {
          BotBehaviour = 8;
          OnlineStatus = 7;
          TradingPreferences = 1;
          RemoteCommunication = 2;
        };
      };
      katedida = {
        passwordFile = "/dev/null";
        settings = {
          BotBehaviour = 8;
          OnlineStatus = 7;
          SendOnFarmingFinished = true;
          SteamUserPermissions = {
            "76561198025431624" = 3;
          };
          RemoteCommunication = 2;
        };
      };
      p0n4ik = {
        username = "p0n4ikakachief666";
        passwordFile = "/dev/null";
        settings = {
          BotBehaviour = 8;
          OnlineStatus = 7;
          SendOnFarmingFinished = true;
          SteamUserPermissions = {
            "76561198025431624" = 3;
          };
          RemoteCommunication = 2;
        };
      };
    };
  };
}
