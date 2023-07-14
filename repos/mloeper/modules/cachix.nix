{ config, lib, ... }:

with lib;

let
  cfg = config.mloeper.cachix;
in {

  options.mloeper.cachix.enable = mkEnableOption "Enable Cachix cache for mloeper NUR";

  config = mkIf cfg.enable {
    nix = {
      binaryCachePublicKeys = [ "nesto.cachix.org-1:lIoJWOEaqqvUmcSzncCwRntE9HP7NopO1Q5HdtN7Jr8=" ];
      binaryCaches = [ https://nesto.cachix.org ];
    };
  };
}