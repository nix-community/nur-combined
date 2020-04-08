{ pkgs, config, lib, ... }:

with builtins;
with lib;

let
  cfg = config.programs.onedrive;

  isEmpty = l: l == [];

  zipWith = f: xs: ys:
    if isEmpty xs || isEmpty ys
    then []
    else [(f (head xs) (head ys))] ++ zipWith f (tail xs) (tail ys);

  attrsToList = attrs:
    zipWith
      (name: value: { inherit name value; })
      (builtins.attrNames attrs)
      (attrValues attrs);

  toOnedriveConfig = config:
    let
      quoted = value:
        let
          value' = replaceStrings [ ''"'' ''\'' ] [ ''\"'' ''\\'' ]
            (toString value);
        in ''"${value'}"'';
      formatOption = { name, value }:
        ''${name} = ${quoted value}'';
    in
      concatStringsSep "\n" (map formatOption (attrsToList config));
in
{
  options = {
    programs.onedrive = {
      enable = mkEnableOption "Whether to enable onedrive.";

      package = mkOption {
        type = with types; package;
        description = "Package to use for ncmpcpp.";
      };

      config = mkOption {
        type = with types;
          attrsOf (either str (either int (either bool path)));
        default = { };
        example = {
          sync_dir = /home/username/OneDrive;
          skip_file = "~*|.~*|*.tmp";
          skip_dir = "~*|.~*|*.tmp";
        };
        description = ''
          Configuration for onedrive.
        '';
      };

      extraConfig = mkOption {
        type = with types; lines;
        default = "";
        example = ''
          sync_dir = /home/username/OneDrive
          skip_file = "~*|.~*|*.tmp"
          skip_dir = "~*|.~*|*.tmp"
        '';
        description = ''
          Extra configuration for onedrive.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."onedrive/config".text =
      toOnedriveConfig cfg.config + cfg.extraConfig;
  };
}
