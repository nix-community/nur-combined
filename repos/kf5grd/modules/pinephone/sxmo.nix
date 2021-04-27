{ config, lib, pkgs ? import <nixpkgs> {}, ... }:
with lib;
let
  cfg = config.pinephone.sxmo;
in
{
  options = {
    pinephone.sxmo = {
      enable = mkOption {
        type = types.bool;
        description = "Whether to write sxmo config files";
        default = false;
      };
      background = mkOption {
        type = types.path;
        description = "Path to desktop background image";
        default = /usr/share/sxmo/background.jpg;
      };
      conkyConfig = mkOption {
        type = types.path;
        description = "Path to conky config";
        default = /usr/share/sxmo/appcfg/conky.conf;
      };
      defaultVolume = mkOption {
        type = types.ints.positive;
        description = "Default volume level to set upon boot as a percentage of volume";
        default = 50;
      };
      defaultAudioOut = mkOption {
        type = types.str;
        description = "Default audio output";
        default = "Speaker";
      };
      startupSound = mkOption {
        type = types.nullOr types.path;
        description = "Path to startup sound. No startup sound if null";
        example = /usr/share/sxmo/startup.ogg;
        default = null;
      };
      enableModem = mkOption {
        type = types.bool;
        description = "Enable modemmonitor on boot";
        default = false;
      };
      xinitExtras = mkOption {
        type = types.nullOr types.str;
        description = "Extras to append to then end of sxmo's xinit";
        default = null;
      };
    };
  };

  config = mkIf cfg.enable {
    home.file.sxmoXinit = {
      executable = true;
      target = "${config.xdg.configHome}/sxmo/xinit";
      text = let
        startupSound = if cfg.startupSound != null then "mpv --quiet --no-video ${builtins.toString cfg.startupSound} &\n" else "";
        enableModem = if cfg.enableModem == true then "sleep 22 && sxmo_modemmonitortoggle.sh on &\n" else "";
        xinitExtras = if cfg.xinitExtras != null then cfg.xinitExtras else "";
      in ''
        feh --bg-fill ${builtins.toString cfg.background}
        conky -c ${builtins.toString cfg.conkyConfig} -d
        sxmo_audioout.sh ${cfg.defaultAudioOut}
        amixer sset 'Line Out Source' 'Mono Differential','Mono Differential'
        amixer set "Line Out" ${builtins.toString cfg.defaultVolume}%
      ''
        +startupSound
        +enableModem
        +xinitExtras;
    };
  };
}
