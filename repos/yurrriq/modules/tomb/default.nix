{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.tomb;
in
{

  options = {

    programs.tomb = {

      enable = mkOption {
        default = false;
        description = ''
          Whether to configure Tomb.
        '';
        type = types.bool;
      };

      fastEntropy = mkOption {
        default = false;
        description = ''
          Whether to enable fast entropy generation for key forging.
        '';
        type = types.bool;
      };

      qrcode = mkOption {
        default = false;
        description = ''
          Whether to enable engraving keys into printable QR code sheets.
        '';
        type = types.bool;
      };

      resize = mkOption {
        default = false;
        description = ''
          Whether to enable extending the size of existing tomb volumes.
        '';
        type = types.bool;
      };

      searchArchives = mkOption {
        default = false;
        description = ''
          Whether to enable fast searching of contents in compressed archives.
        '';
        type = types.bool;
      };

      searchContents = mkOption {
        default = false;
        description = ''
          Whether to enable fast searching of file contents inside tombs.
        '';
        type = types.bool;
      };

      searchDocuments = mkOption {
        default = false;
        description = ''
          Whether to enable fast searching of contents in PDF and DOC files.
        '';
        type = types.bool;
      };

      searchNames = mkOption {
        deafult = false;
        description = ''
          Whether to enable fast searching of file names inside tombs.
        '';
        type = types.bool;
      };

      showProgress = mkOption {
        default = false;
        description = ''
          Whether to show progress while digging tombs and keys.
        '';
        type = types.bool;
      };

      slam = mkOption {
        default = false;
        description = ''
          Whether to enable slamming a tomb.
        '';
        type = types.bool;
      };

      steganography = mkOption {
        default = false;
        description = ''
          Whether to enable burying and exhuming keys inside images.
        '';
        type = types.bool;
      };

    };

  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; (
      [ file tomb ]
      ++ optional cfg.slam lsof
      ++ optional cfg.qrcode libqrencode
      ++ optional cfg.steganography steghide
    );
  };

}
