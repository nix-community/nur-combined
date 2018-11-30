{ config, lib, ... }:

with lib;

let
  cfg = config.kreisys.cachix;
in {

  options.kreisys.cachix.enable = mkEnableOption "Enable Cachix cache for kreisys NUR";

  config = mkIf cfg.enable {
    nix = {
      binaryCachePublicKeys = [ "kreisys.cachix.org-1:RMqfdpzxeRcoND7pD5l0EcFfjEIYBbOR5WF2CQyxPyE=" ];
      binaryCaches = [ https://kreisys.cachix.org ];
    };
  };
}
