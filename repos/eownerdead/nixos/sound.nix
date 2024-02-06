{ lib, pkgs, config, ... }:
with lib; {
  options.eownerdead.sound = mkEnableOption (mdDoc ''
    See the (wiki)[https://nixos.wiki/wiki/PipeWire]
  '');

  config = mkIf config.eownerdead.sound {
    sound.enable = mkDefault true;

    services.pipewire = {
      enable = mkDefault true;
      alsa.enable = mkDefault true;
      pulse.enable = mkDefault true;
    };
  };
}

