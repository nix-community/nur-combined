{ pkgs, config, lib, ... }:

with builtins;
with lib;

let
  cfg = config.programs.ncmpcpp;

  bindingsFile = "ncmpcpp/bindings";
  configFile = "ncmpcpp/config";

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

  toNcmpcppBindings = bindings:
    let
      bindings' = map
        ({ name, value }: { key = name; actions = value; })
        (attrsToList bindings);

      formatSingleAction = action: "  " + action;
      formatChainOfActions = chain:
        concatStringsSep "\n" (map formatSingleAction chain);
      formatAction = action:
        if isList action then formatChainOfActions action
        else formatSingleAction action;

      formatKey = key:
        let key' = replaceStrings [ ''\'' ''"'' ] [ ''\\'' ''"'' ] key; in
        ''"${key'}"'';

      formatBinding = { key, actions }:
        concatStringsSep "\n"
          (map
            (action: "def_key ${formatKey key}\n${formatAction action}")
            actions
          );
    in
      concatStringsSep "\n" (map formatBinding bindings');

  toNcmpcppConfig = config:
    let
      config' = attrsToList config;

      quoted = v:
        if hasPrefix " " v || hasSuffix " " v
        then ''"${v}"''
        else v;

      formatValue = value:
        if isString value then quoted value
        else if isBool value then (if value then "yes" else "no")
        else if isList value then concatStringsSep ", " (map formatValue value)
        else toString value;

      formatNameValue = { name, value }: "${name} = ${formatValue value}";
    in
      concatStringsSep "\n" (map formatNameValue config');
in
{
  options = {
    programs.ncmpcpp = {
      enable = mkEnableOption "Whether to enable ncmpcpp.";

      package = mkOption {
        type = types.package;
        default = pkgs.ncmpcpp;
        description = "Package to use for ncmpcpp.";
      };

      configDirectory = mkOption {
        type = types.str;
        default = "ncmpcpp";
        description = ''
          Directory in <literal>xdg.configHome</literal> to store
          ncmpcpp configuration files in. This option can be
          overridden by specifying
          <literal>ncmpcpp_directory</literal> in
          <literal>programs.ncmpcpp.config</literal>. This option is
          present to prevent ncmpcpp from making a directory
          <literal>~/.ncmpcpp</literal>, which it does by default if
          <literal>ncmpcpp_directory</literal> is not specified in the
          configuration.

          If the value is an empty string, the
          <literal>ncmpcpp_directory</literal> option will not be set.
        '';
      };

      bindings = mkOption {
        type = with types; attrsOf (listOf (either str (listOf str)));
        default = { };
        example = {
          enter = [
            "play_item"
          ];
          "3" = [
            "show_search_engine"
            "reset_search_engine"
          ];
          shift-k = [
            [ "select_item" "scroll_up" ]
          ];
        };
        description = ''
          Key bindings for ncmpcpp. This is a set where the names are keys
          (e.g.: <literal>d</literal>, <literal>ctrl-r</literal>,
          <literal>"\\"</literal>). The values are lists of either strings or
          lists of strings. The strings are actions, like
          <literal>"reverse_playlist"</literal>. The lists are chains of
          actions; every action in the list will be run until the end is reached
          or one of the actions fails.
        '';
      };

      config = mkOption {
        type = with types;
          let simpleValue = either str (either int (either bool path)); in
          attrsOf (either simpleValue (listOf simpleValue));
        default = { };
        example = {
          mpd_port = 6600;
          visualizer_in_stereo = true;
          visualizer_sync_interval = 30;
          visualizer_type = "wave";
          visualizer_color = [ "blue" "cyan" "green" "yellow" "magenta" "red" ];
        };
        description = ''
          Configuration for ncmpcpp. The format is very straightforward, with
          two exceptions: booleans are translated to <literal>yes</literal> and
          <literal>no</literal>, and lists are formatted with commas as
          separators. The list <literal>[ "a" "b" "c" ]</literal> is formatted
          as <literal>a, b, c</literal>, for instance.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile.${bindingsFile}.text = toNcmpcppBindings cfg.bindings;
    xdg.configFile.${configFile}.text =
      let c = if cfg.configDirectory == ""
              then cfg.config
              else { ncmpcpp_directory =
                       config.xdg.configHome + "/" + cfg.configDirectory;
                   } // cfg.config;
      in toNcmpcppConfig c;
  };
}
