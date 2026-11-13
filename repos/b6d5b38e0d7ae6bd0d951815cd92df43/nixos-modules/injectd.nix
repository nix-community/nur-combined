{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.injectd;
in
{
  options.services.injectd = {
    enable = mkEnableOption "Inject Custom Boot Messages";
    
    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../pkgs/injectd {};
      description = "The injectd package to use.";
    };
    
    mode = mkOption {
      type = types.enum [ "nsfw" "matrix" "custom" ];
      default = "matrix";
      description = "The boot message mode to use.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.injectd = {
      description = "Inject Custom Boot Messages";
      wantedBy = [ "basic.target" ];
      before = [ "basic.target" ];
      after = [ "sysinit.target" "local-fs.target" ];
      unitConfig.DefaultDependencies = false;
      
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/bin/injectd --run-boot-injection";
        StandardOutput = "journal+console";
        TimeoutStartSec = 10;
      };
      
      preStart = ''
        mkdir -p /opt/injectd
        case "${cfg.mode}" in
          nsfw) cp ${cfg.package}/share/injectd/messagesNSFW.txt /opt/injectd/active_messages.txt ;;
          matrix) cp ${cfg.package}/share/injectd/messagesMatrix.txt /opt/injectd/active_messages.txt ;;
          custom)
            if [ -f /etc/injectd/messagesCustom.txt ]; then
              cp /etc/injectd/messagesCustom.txt /opt/injectd/active_messages.txt
            else
              cp ${cfg.package}/share/injectd/messagesCustom.txt /opt/injectd/active_messages.txt
            fi
            ;;
        esac
      '';
    };
    
    environment.systemPackages = [ cfg.package ];
  };
}
