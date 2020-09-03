{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.kakoune;
in
{
  options = {
    programs.kakoune = {
      colors = mkOption {
        type = types.listOf types.path;
        default = [];
        description = "kakoune color schemes";
      };

      pluginsExt = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "kakoune plugins";
      };
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile = listToAttrs (map (source:
      nameValuePair "kak/colors/${builtins.baseNameOf source}" { inherit source; }
    ) cfg.colors);

    programs.kakoune.extraConfig = let
      sourceString = s: if s ? kakrc then "source ${s.kakrc}" else "source ${s}";
    in lib.optionalString (cfg.pluginsExt != []) ''
      # Plugins
      ${concatStringsSep "\n" (map sourceString cfg.pluginsExt)}
    '';
  };
}
