{ config, lib, ... }:

with lib;
let
  cfg = config.priegger.services.cachix;
in
{
  options.priegger.services.cachix = {
    enable = mkEnableOption "Enable Cachix cache for priegger NUR";
  };

  config = mkIf cfg.enable {
    nix.settings = {
      substituters = [
        "https://priegger.cachix.org"
      ];
      trusted-public-keys = [
        "priegger.cachix.org-1:+XZ+nLI5dMog2407JiLxum9d8tjIhojIvbgE8OKEatA="
      ];
    };
  };
}
