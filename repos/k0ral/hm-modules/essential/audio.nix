{ config, lib, pkgs ? import <nixpkgs> { }, ... }:
with lib;

let cfg = config.module.essential.audio;
in {
  options.module.essential.audio = {
    enable = mkEnableOption "Essential audio tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      alsaUtils
      flac
      ncpamixer
      opusTools
      pamixer
      paprefs
      pavucontrol
      playerctl
      r128gain
      vorbis-tools

      (writeShellScriptBin "select-sink" ''
        SINK=$(${pulseaudio}/bin/pactl list sinks | grep Name | cut -d" " -f2- | ${fzf}/bin/fzf)
        ${pulseaudio}/bin/pactl set-default-sink "$SINK"
      '')
    ];

    services.playerctld.enable = true;
  };
}
