{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.pipewire;
in {
  options.programs.pipewire = {
    enable = mkEnableOption ''
      the PipeWire sound server
    '';
  };

  config = mkIf cfg.enable {
    nixpkgs.config.pulseaudio = true;
    programs.dconf.enable = mkDefault true;
    environment = {
      systemPackages = with pkgs; [ pavucontrol ];
    };
    services.pipewire.enable = true;
    services.pipewire.pulse.enable = true;
    services.pipewire.jack.enable = true;
    security.rtkit.enable = true;
  };
}
