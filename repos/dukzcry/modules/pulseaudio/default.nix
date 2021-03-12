{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.pulseaudio;
in {
  options.services.pulseaudio = {
    enable = mkEnableOption ''
      the PulseAudio sound server
    '';
  };

  config = mkIf cfg.enable {
    sound.enable = lib.mkForce false;
    hardware.pulseaudio.enable = true;
    programs.dconf.enable = true;
    environment = {
      systemPackages = with pkgs; [ pavucontrol pulseeffects ];
    };
  };
}
