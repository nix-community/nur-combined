{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.containers.openshift;
in
{
  options = {
    profiles.containers.openshift = {
      enable = mkEnableOption "Enable openshift profile";
      package = mkOption {
        default = pkgs.my.oc;
        description = "Openshift package";
        type = types.package;
      };
      minishift = {
        enable = mkEnableOption "Enable minishift";
        package = mkOption {
          default = pkgs.minishift;
          description = "Minishift package";
          type = types.package;
        };
      };
      crc = mkEnableOption "Enable crc";
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      profiles.containers.kubernetes.enable = true;
      home.packages = with pkgs; [
        cfg.package
        #my.openshift-install
        my.operator-sdk
      ];
    }
    (
      mkIf cfg.minishift.enable {
        home.packages = with pkgs; [
          cfg.minishift.package
          docker-machine-kvm
          docker-machine-kvm2
        ];
      }
    )
    (
      mkIf cfg.crc {
        home.packages = with pkgs; [
          my.crc
        ];
      }
    )
  ]);
}
