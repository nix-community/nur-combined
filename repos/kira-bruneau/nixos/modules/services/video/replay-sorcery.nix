{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.replay-sorcery;

  kmsRequired = cfg.settings ? videoInput && builtins.any
    (kmsInput: cfg.settings.videoInput == kmsInput)
    [ "hwaccel" "kms_service" ];

  configFile = generators.toKeyValue { } cfg.settings;
in
{
  imports = [
    (mkRemovedOptionModule [ "services" "replay-sorcery" "enableSysAdminCapability" ]
      "No longer relevant now that ReplaySorcery manages hardware acceleration through a separate service.")
  ];

  options = with types; {
    services.replay-sorcery = {
      enable = mkEnableOption (lib.mdDoc "the ReplaySorcery service for instant-replays");

      autoStart = mkOption {
        type = bool;
        default = true;
        description = lib.mdDoc "Automatically start ReplaySorcery when graphical-session.target starts.";
      };

      settings = mkOption {
        type = attrsOf (oneOf [ str int ]);
        default = { };
        description = lib.mdDoc "System-wide configuration for ReplaySorcery (/etc/replay-sorcery.conf).";
        example = literalExpression ''
          {
            videoInput = "hwaccel";
            videoFramerate = 60;
          }
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [ pkgs.replay-sorcery ];
      etc."replay-sorcery.conf".text = configFile;
    };

    systemd = {
      packages = [ pkgs.replay-sorcery ];

      user.services.replay-sorcery = mkIf cfg.autoStart {
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
      };

      services.replay-sorcery-kms = mkIf (cfg.autoStart && kmsRequired) {
        wantedBy = [ "graphical.target" ];
        partOf = [ "graphical.target" ];
      };
    };
  };

  meta = {
    maintainers = with maintainers; [ kira-bruneau ];
  };
}
