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
    nixpkgs.config.pulseaudio = true;
    programs.dconf.enable = true;
    environment = {
      systemPackages = with pkgs; [ pavucontrol pulseeffects ];
    };
    hardware.pulseaudio.configFile = pkgs.runCommand "default.pa" {} ''
      sed 's/module-udev-detect$/module-udev-detect tsched_buffer_size=60000/' \
        ${pkgs.pulseaudio}/etc/pulse/default.pa > $out
    '';
  };
}
