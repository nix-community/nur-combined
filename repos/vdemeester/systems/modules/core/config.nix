{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles;
in
{
  # This options are mainly used for user side for now
  # aka, in users/vincent, there is a check if these are enabled, to conditionnally
  # add something to the user environments
  # This shouldn't prevent to have real thing behind this
  options = {
    profiles.kubernetes = {
      enable = mkEnableOption "Enable Kubernetes profile";
    };
    profiles.openshift = {
      enable = mkEnableOption "Enable OpenShift profile";
      crc.enable = mkEnableOption "Enable CodeReady Containers";
    };
    profiles.tekton = {
      enable = mkEnableOption "Enable Tekton profile";
    };
  };
}
