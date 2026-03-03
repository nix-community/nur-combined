{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.ld-decode;
  maintainers = import ../../maintainers.nix;
in
{
  options.programs.ld-decode = {
    enable = lib.mkEnableOption "ld-decode";
    package = lib.mkPackageOption pkgs "ld-decode" {
      default = [
        "ld-decode"
      ];
    };

    exportVersionVariable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Set the environment variable __LD_DECODE_VERSION.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = [
        cfg.package
      ];

      variables = lib.mkIf cfg.exportVersionVariable {
        "__LD_DECODE_VERSION" = cfg.package.version;
      };
    };
  };

  meta = {
    inherit maintainers;
  };
}
