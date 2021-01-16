{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.jack;
in {
  options.services.jack = {
    enable = mkEnableOption ''
      JACK Audio Connection Kit. You must be in "wheel" group
    '';
  };

  config = mkIf cfg.enable {
    security.pam.loginLimits = [
      { domain = "@wheel"; type = "-"; item = "rtprio"; value = "99"; }
      { domain = "@wheel"; type = "-"; item = "memlock"; value = "unlimited"; }
    ];
    sound.extraConfig = ''
      pcm_type.jack {
        libs.native = ${pkgs.alsaPlugins}/lib/alsa-lib/libasound_module_pcm_jack.so ;
      }
    '';
    environment = {
      systemPackages = with pkgs; [ qjackctl a2jmidid jack2 ];
      etc."alsa/conf.d/50-jack.conf".source = "${pkgs.alsaPlugins}/etc/alsa/conf.d/50-jack.conf";
    };
  };
}
