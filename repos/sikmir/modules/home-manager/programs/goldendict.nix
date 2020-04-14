{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.goldendict;
in
{
  meta.maintainers = with maintainers; [ sikmir ];

  options.programs.goldendict = {
    enable = mkEnableOption "A feature-rich dictionary lookup program";

    package = mkOption {
      default = pkgs.goldendict;
      defaultText = literalExample "pkgs.goldendict";
      description = "GoldenDict package to install.";
      type = types.package;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
