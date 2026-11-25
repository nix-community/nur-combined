{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.programs.honk;
in
{
  options.programs.honk = {
    enable = mkEnableOption "honk command-line tools";
    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../pkgs/tools/honk/binary.nix { };
      defaultText = lib.literalExpression "honk-bin";
      description = "Honk package to install.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
