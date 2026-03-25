{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.decode;
  maintainers = import ../../maintainers.nix;
in
{
  options.programs.decode = {
    enable = lib.mkEnableOption "Enable decode packages.";

    package = lib.mkPackageOption pkgs "vhs-decode" {
      default = [
        "vhs-decode"
      ];
      example = ''
        ld-decode
      '';
    };

    toolsPackage = lib.mkPackageOption pkgs "vhs-decode-tools" {
      default = [
        "vhs-decode-tools"
      ];
      example = ''
        ld-decode-tools
      '';
    };

    exportVersionVariable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Set the environment variables __DECODE_VERSION and __DECODE_TOOLS_VERSION.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = [
        cfg.package
        cfg.toolsPackage
      ];

      variables = lib.mkIf cfg.exportVersionVariable {
        "__DECODE_VERSION" = cfg.package.version;
        "__DECODE_TOOLS_VERSION" = cfg.toolsPackage.version;
      };
    };
  };

  meta = {
    inherit maintainers;
  };
}
