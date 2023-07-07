{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nur.ilya-fedin.cache;
in {
  options = {
    nur.ilya-fedin.cache = {
      enable = mkEnableOption "Whether to enable binary cache for ilya-fedin's NUR.";
    };
  };

  config = mkIf cfg.enable {
    nix.settings = {
      substituters = [ "https://ilya-fedin.cachix.org" ];
      trusted-public-keys = [
        "ilya-fedin.cachix.org-1:QveU24a5ePPMh82mAFSxLk1P+w97pRxqe9rh+MJqlag="
      ];
    };
  };
}
