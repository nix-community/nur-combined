{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.bitwig;
  bitwig-studio' = pkgs.bitwig-studio.overrideAttrs (oldAttrs: {
    postFixup = ''
      ${oldAttrs.postFixup}
      wrapProgram $out/bin/bitwig-studio \
        --run "${pkgs.alsaUtils}/bin/aconnect 'microKEY2-25 Air' 'Virtual Raw MIDI 1-0'"
    '';
  });
in {
  options.programs.bitwig = {
    enable = mkEnableOption ''
      Bitwig Studio
    '';
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [ bitwig-studio' ];
    };
    boot.kernelModules = [ "snd_virmidi" ];
    boot.extraModprobeConfig = ''
      options snd_virmidi midi_devs=1
    '';
  };
}
