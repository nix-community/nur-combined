{ config, lib, pkgs ? import <nixpkgs> { }, ... }:
with lib;

let
  cfg = config.module.mpv;
in {
  options.module.mpv = {
    enable = mkEnableOption "mpv module";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (writeScriptBin "play" ''
        #!${pkgs.bash}/bin/bash
        mpv --hwdec=auto "$@"
      '')
      (writeScriptBin "splay" ''
        #!${pkgs.bash}/bin/bash
        mpv --no-audio "$@"
      '')
    ];

    programs.mpv = {
      enable = true;
      config = {
        audio-display = false;
        keep-open = "always";
      };
      bindings = { F2 = ''af toggle "lavfi=[dynaudnorm=f=75:g=25:n=0:p=0.58]"''; };
    };
  };
}
