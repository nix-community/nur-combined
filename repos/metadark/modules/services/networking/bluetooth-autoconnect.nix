{ config, lib, pkgs, ... }:

with lib;
let
  nur = import ../../.. { inherit pkgs; };
  cfg = config.services.bluetooth-autoconnect;
  bluetooth-autoconnect = nur.bluetooth-autoconnect;
in
{
  options.services.bluetooth-autoconnect = {
    enable = mkEnableOption ''
      bluetooth autoconnect to automatically connect to all paired and
      trusted bluetooth devices'';
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.hardware.bluetooth.enable;
        message = ''
          Bluetooth autoconnect requires hardware.bluetooth.enable to be true
        '';
      }
    ];

    systemd = {
      services = {
        bluetooth-autoconnect = {
          description = "Bluetooth autoconnect service";
          wantedBy = [ "bluetooth.service" ];
          before = [ "bluetooth.service" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${bluetooth-autoconnect}/bin/bluetooth-autoconnect -d";
          };
        };
      };

      user.services = mkMerge [
        (mkIf config.hardware.pulseaudio.enable {
          pulseaudio-bluetooth-autoconnect = {
            description = "Bluetooth autoconnect service for pulseaudio";
            wantedBy = [ "pulseaudio.service" ];
            after = [ "pulseaudio.service" ];
            serviceConfig = {
              Type = "simple";
              ExecStart = "${bluetooth-autoconnect}/bin/bluetooth-autoconnect";
            };
          };
        })
        (mkIf (config.services.pipewire.enable && config.services.pipewire.pulse.enable) {
          pipewire-bluetooth-autoconnect = {
            description = "Bluetooth autoconnect service for pipewire";
            wantedBy = [ "pipewire.service" ];
            after = [ "pipewire.service" "pipewire-pulse.service" ];
            serviceConfig = {
              Type = "simple";

              # PipeWire is currently a simple service, so we can't know for sure when it will be ready
              ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";

              ExecStart = "${bluetooth-autoconnect}/bin/bluetooth-autoconnect";
            };
          };
        })
      ];
    };
  };

  meta = {
    maintainers = with maintainers; [ kira-bruneau ];
  };
}
