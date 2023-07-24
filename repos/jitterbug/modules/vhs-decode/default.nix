{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.programs.vhs-decode;
in
{
  options.programs.vhs-decode = {
    enable = mkEnableOption "vhs-decode";
    package = mkPackageOption pkgs "vhs-decode" { default = [ "vhs-decode" ]; };

    exportVersionVariable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Set the environment variable __VHS_DECODE_VERSION.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [ cfg.package ];
      variables = mkIf cfg.exportVersionVariable {
        "__VHS_DECODE_VERSION" = cfg.package.version;
      };
    };
  };
}
