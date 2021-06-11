{ config, lib, pkgs, ... }:

with lib;

let
  nur = import ../.. { inherit pkgs; };
  cfg = config.programs.gamemode;
  settingsFormat = pkgs.formats.ini { };
  configFile = settingsFormat.generate "gamemode.ini" cfg.settings;
in
{
  options = {
    programs.gamemode = {
      enable = mkEnableOption "GameMode to optimise system performance on demand";

      enableRenice = mkEnableOption "CAP_SYS_NICE on gamemoded to support lowering process niceness" // {
        default = true;
      };

      settings = mkOption {
        type = settingsFormat.type;
        default = {};
        description = ''
          System-wide configuration for GameMode (/etc/gamemode.ini).
          See gamemoded(8) man page for available settings.
        '';
        example = literalExample ''
          {
            general = {
              renice = 10;
            };

            # Warning: GPU optimisations have the potential to damage hardware
            gpu = {
              apply_gpu_optimisations = "accept-responsibility";
              gpu_device = 0;
              amd_performance_level = "high";
            };

            custom = {
              start = "''${pkgs.libnotify}/bin/notify-send 'GameMode started'";
              end = "''${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
            };
          }
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [ nur.gamemode ];
      etc."gamemode.ini".source = configFile;
    };

    security = {
      polkit.enable = true;
      wrappers = mkIf cfg.enableRenice {
        gamemoded = {
          source = "${nur.gamemode}/bin/gamemoded";
          capabilities = "cap_sys_nice+ep";
        };
      };
    };

    systemd = {
      packages = [ nur.gamemode ];
      user.services.gamemoded.serviceConfig = {
        Environment = [
          # Use pkexec from the security wrappers to allow users to
          # run libexec/cpugovctl & libexec/gpuclockctl as root with
          # the the actions defined in share/polkit-1/actions.
          #
          # Use a link farm to make sure other wrapped executables
          # aren't included in PATH.
          "PATH=${pkgs.linkFarm "pkexec" [
            {
              name = "pkexec";
              path = "${config.security.wrapperDir}/pkexec";
            }
          ]}"
        ];

        ExecStart = mkIf cfg.enableRenice [
          "" # Tell systemd to clear the existing ExecStart list, to prevent appending to it.
          "${config.security.wrapperDir}/gamemoded"
        ];
      };
    };
  };

  meta = {
    maintainers = with maintainers; [ kira-bruneau ];
  };
}
