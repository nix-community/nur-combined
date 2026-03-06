{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.xserver.xkb.neolight;
  neolightPkg = pkgs.callPackage ../pkgs/neolight { };
in
{
  _class = "nixos";

  options.services.xserver.xkb.neolight = {
    package = lib.mkOption {
      type = lib.types.package;
      default = neolightPkg;
      defaultText = lib.literalExpression "nur.repos.drafolin.neolight";
      description = "The neolight package to use.";
    };
    enable = lib.mkEnableOption "neolight xkb layout, extra keyboard layers for programming based on Neo";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    environment.sessionVariables.XKB_CONFIG_ROOT = lib.mkForce "${cfg.package}/share/X11/xkb";

    assertions = [
      {
        assertion = config.services.xserver.xkb.extraLayouts == { };
        message = "Neolight conflicts with xkb.extraLayouts";
      }
    ];
  };

  meta.maintainers = with lib.maintainers; [ drafolin ];
}
