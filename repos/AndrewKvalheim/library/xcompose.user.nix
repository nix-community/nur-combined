{ config, lib, ... }:

let
  inherit (builtins) attrValues sort tail;
  inherit (config) xcompose;
  inherit (config.home) homeDirectory;
  inherit (lib) concatLines concatMapStringsSep genAttrs hasPrefix id init mapAttrsToList mkIf mkOption stringToCharacters zipLists;
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
      "$" = "dollar";
    };
in
{
  options.xcompose = {
    sequences = mkOption { type = attrsOf str; };
  };

  config =
    mkIf (xcompose ? "sequences") {
      assertions = let sorted = sort (a: b: a < b) (attrValues xcompose.sequences); in map
        ({ fst, snd }: {
          assertion = ! hasPrefix fst snd;
          message = "Compose sequence collision: ${fst}";
        })
        (zipLists (init sorted) (tail sorted));

      home.file.".XCompose" = {
        onChange = "rm -rfv ${homeDirectory}/.cache/gtk-3.0/compose";
        text = concatLines (mapAttrsToList
          (glyph: sequence:
            let keys = [ "Multi_key" ] ++ (map (c: names.${c}) (stringToCharacters sequence));
            in "${concatMapStringsSep " " (k: "<${k}>") keys} : \"${glyph}\"")
          xcompose.sequences);
      };
    };
}
