{ config, lib, pkgs, ... }:

let
  inherit (lib) mkOption mkEnableOption types;

  cfg = config.programs.rofi-snippets;
  rofi-snippets-pkg = pkgs.callPackage ../../pkgs/top-level/rofi-snippets {};
  json = pkgs.formats.json {};
in
{
  options.programs.rofi-snippets = {
    enable = mkEnableOption "rofi-snippets";

    package = mkOption {
      type = types.package;
      default = rofi-snippets-pkg;
      defaultText = lib.literalExpression "nur-dcsunset.packages.rofi-snippets";
      description = "The rofi-snippets package to use (e.g. package from nur)";
    };

    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      description = "Resulting customized rofi-snippets package";
    };

    features = mkOption {
      type = types.nullOr (types.listOf (types.enum [ "wayland" "x11" ]));
      default = null;
      description = "Features for rofi-snippets package";
    };

    settings = mkOption {
      type = json.type;
      default = {};
      description = "JSON config for rofi-snippets";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.rofi-snippets.finalPackage =
      if builtins.hasAttr "override" cfg.package && cfg.features != null then
        cfg.package.override { inherit (cfg) features; }
      else
        cfg.package;

    programs.rofi.plugins = [ cfg.finalPackage ];

    home.file."${config.xdg.configHome}/rofi-snippets/config.json".source = json.generate "config.json" cfg.settings;
  };
}
