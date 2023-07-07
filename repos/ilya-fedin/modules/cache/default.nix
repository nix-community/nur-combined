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
    nix.settings = import ../../nix-config.nix;
  };
}
