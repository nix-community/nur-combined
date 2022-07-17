{
  config,
  lib,
  ...
}: let
  inherit (lib) literalExpression mkIf mkOption types;
  cfg = config.sigprof.nixpkgs;
in {
  options = {
    sigprof.nixpkgs.permittedUnfreePackages = mkOption {
      type = types.listOf types.str;
      default = [];
      example = literalExpression "[\"hplip\"]";
      description = ''
        List of package names that would be permitted to use despite having an
        unfree license.
      '';
    };
  };

  config = mkIf (cfg.permittedUnfreePackages != []) {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) cfg.permittedUnfreePackages;
  };
}
