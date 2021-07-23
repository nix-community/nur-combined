{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.jack;
  pulse = cfg.enable && config.hardware.pulseaudio.enable;
  alsa = cfg.enable && config.sound.enable && !config.hardware.pulseaudio.enable;
in {
  options.services.jack = {
    enable = mkEnableOption ''
      JACK Audio Connection Kit. You must be in "wheel" group
    '';
  };

  config = mkMerge [

   (mkIf cfg.enable {
      security.pam.loginLimits = [
        { domain = "@wheel"; type = "-"; item = "rtprio"; value = "99"; }
        { domain = "@wheel"; type = "-"; item = "memlock"; value = "unlimited"; }
      ];
      environment.systemPackages = with pkgs; [ qjackctl a2jmidid jack2 ];
   })
   (mkIf alsa {
      sound.extraConfig = ''
        pcm_type.jack {
          libs.native = ${pkgs.alsaPlugins}/lib/alsa-lib/libasound_module_pcm_jack.so ;
       }
      '';
      environment.etc."alsa/conf.d/50-jack.conf".source = "${pkgs.alsaPlugins}/etc/alsa/conf.d/50-jack.conf";
   })
   (mkIf pulse {
      hardware.pulseaudio.package = pkgs.pulseaudioFull;
   })
  ];
}
