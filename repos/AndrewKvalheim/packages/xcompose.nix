{ config, lib, ... }:

let
  inherit (lib) concatLines concatMapStringsSep genAttrs id mapAttrsToList mkIf mkOption stringToCharacters;
  inherit (lib.types) attrsOf str;

  names =
    (genAttrs (stringToCharacters "0123456789abcdefghijklmnopqrstuvwxyz") id) //
    {
      " " = "space";
      "_" = "underscore";
      "-" = "minus";
      "," = "comma";
      ";" = "semicolon";
      ":" = "colon";
      "!" = "exclam";
      "?" = "question";
      "." = "period";
      "'" = "apostrophe";
      "(" = "parenleft";
      ")" = "parenright";
      "\"" = "quotedbl";
      "/" = "slash";
      "`" = "grave";
      "^" = "asciicircum";
      "+" = "plus";
      "<" = "less";
      "=" = "equal";
      ">" = "greater";
      "|" = "bar";
      "~" = "asciitilde";
    };
in
{
  options.xcompose = {
    sequences = mkOption { type = attrsOf str; };
  };

  config =
    mkIf (config.xcompose ? "sequences") {
      home.file.".XCompose" = {
        onChange = "rm -rfv ${config.home.homeDirectory}/.cache/gtk-3.0/compose";
        text = concatLines (mapAttrsToList
          (glyph: sequence:
            let keys = [ "Multi_key" ] ++ (map (c: names.${c}) (stringToCharacters sequence));
            in "${concatMapStringsSep " " (k: "<${k}>") keys} : \"${glyph}\"")
          config.xcompose.sequences);
      };
    };
}
