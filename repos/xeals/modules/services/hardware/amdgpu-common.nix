{ config, lib, pkgs, ... }:

with lib;

{
  options.services.amdgpu = {
    cards = mkOption {
      type = types.listOf types.str;
      default = [ "card0" ];
      example = [ "card0" "card1" ];
      description = ''
        A list of cards to enable fan configuration for. The identifiers for
        each device can be found in /sys/class/drm/ as card0, card1, etc.
      '';
    };
  };
}
