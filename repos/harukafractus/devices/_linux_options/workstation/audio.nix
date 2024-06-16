{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.workstation.audio;
in {
  options.workstation.audio = {
    enable = mkEnableOption "Enable PipeWire-based audio drivers";
  };

  config = mkIf cfg.enable {
    # Enable PipeWire
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # The rt modules give real-time priorities to PipeWire
    security.rtkit.enable = true;
  };
}
