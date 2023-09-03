{ config, lib, pkgs, ... }:

let
  cfg = config.programs.gns3-gui;

in {
  meta.maintainers = [ lib.maintainers.anthonyroussel ];

  options = {
    programs.gns3-gui = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''Whether to install the GNS3 GUI client.'';
      };

      package = lib.mkPackageOptionMD pkgs "gns3-gui" {};

      extraPackages = mkOption {
        type = with types; listOf package;
        default = with pkgs; [
          inetutils
          tigervnc
          wireshark
        ];
        defaultText = literalExpression ''
          with pkgs; [ inetutils tigervnc wireshark ];
        '';
      };
    };
  };

  config =
    mkIf cfg.enable (mkMerge [
      {
        environment.systemPackages = optional (cfg.package != null) cfg.package ++ cfg.extraPackages;
      }
    ]);
}
