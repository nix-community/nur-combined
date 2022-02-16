{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.pulseaudio;
  package = pkgs.nur.repos.dukzcry.pulseaudio;
in {
  options.programs.pulseaudio = {
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
      systemPackages = with pkgs; [ pavucontrol pulseeffects-legacy ];
    };
    # pactl list short modules
    #hardware.pulseaudio.configFile = pkgs.runCommand "default.pa" {} ''
    #  sed -e 's/module-udev-detect$/module-udev-detect tsched=0/' \
    #    ${package}/etc/pulse/default.pa > $out
    #'';
    hardware.pulseaudio.package = package;
  };
}
