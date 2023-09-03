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

      extraPackages = lib.mkOption {
        type = with lib.types; listOf package;
        default = with pkgs; [
          inetutils
          tigervnc
          wireshark
        ];
        defaultText = lib.literalExpression ''
          with pkgs; [ inetutils tigervnc wireshark ];
        '';
      };
    };
  };

  config =
    lib.mkIf cfg.enable (lib.mkMerge [
      {
        environment.systemPackages = lib.optional (cfg.package != null) cfg.package ++ cfg.extraPackages;
      }
    ]);
}
