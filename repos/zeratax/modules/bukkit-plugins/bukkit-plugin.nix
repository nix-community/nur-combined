{
  lib,
  pkgs,
  ...
}:
with lib;
  types.submodule ({config, ...}: let
    settingsFormat = pkgs.formats.yaml {};
  in {
    options = {
      package = mkOption {
        type = types.nullOr types.package;
        example = "pkgs.bukkit-plugins.harbor";
        description = ''
          The package for the plugin.
        '';
      };

      settings = mkOption {
        type = types.attrsOf settingsFormat.type;
        default = null;
        example = literalExample ''
          {
            "Harbor/config.yml" = {
              blacklist = [
                "world_nether"
                "world_the_end"
              ]
            }
          };
        '';
        description = ''
          Configuration files for plugin
        '';
      };

      prepareScript = mkOption {
        type = types.str;
        default = "";
        description = ''
          Script that prepares the plugin.
        '';
      };
    };
  })
