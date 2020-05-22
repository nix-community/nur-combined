{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.cloud.google;
in
{
  options = {
    profiles.cloud.google = {
      enable = mkEnableOption "Enable google cloud profile";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ google-cloud-sdk gcsfuse ]; #google-compute-engine
  };
}
