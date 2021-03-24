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
    sound.enable = mkForce false;
    hardware.pulseaudio.enable = true;
    nixpkgs.config.pulseaudio = true;
    programs.dconf.enable = true;
    environment = {
      systemPackages = with pkgs; [ pavucontrol pulseeffects ];
    };
    #hardware.pulseaudio.configFile = pkgs.runCommand "default.pa" {} ''
    #  sed 's/module-udev-detect$/module-udev-detect tsched=0/' \
    #    ${pkgs.pulseaudio}/etc/pulse/default.pa > $out
    #'';
  };
}
