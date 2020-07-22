{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.bluetooth-autoconnect;
  bluetooth-autoconnect = pkgs.nur.repos.metadark.bluetooth-autoconnect;
in
{
  options.services.bluetooth-autoconnect = {
    enable = mkEnableOption ''
      bluetooh autoconnect to automatically connect to all paired and
      trusted bluetooth devices.
    '';
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

      user.services = mkIf config.hardware.pulseaudio.enable {
        pulseaudio-bluetooth-autoconnect = {
          description = "Bluetooth autoconnect service for pulseaudio";
          wantedBy = [ "pulseaudio.service" ];
          after = [ "pulseaudio.service" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${bluetooth-autoconnect}/bin/bluetooth-autoconnect";
          };
        };
      };
    };
  };
}
