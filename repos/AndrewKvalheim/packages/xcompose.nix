{ config, lib, ... }:

let
  inherit (lib) concatLines concatMapStringsSep mapAttrsToList mkIf mkOption stringToCharacters;
  inherit (lib.types) attrsOf str;

  names =
    {
      "0" = "0";
      "1" = "1";
      "2" = "2";
      "3" = "3";
      "4" = "4";
      "5" = "5";
      "6" = "6";
      "7" = "7";
      "8" = "8";
      "9" = "9";

      "a" = "a";
      "b" = "b";
      "c" = "c";
      "d" = "d";
      "e" = "e";
      "f" = "f";
      "g" = "g";
      "h" = "h";
      "i" = "i";
      "j" = "j";
      "k" = "k";
      "l" = "l";
      "m" = "m";
      "n" = "n";
      "o" = "o";
      "p" = "p";
      "q" = "q";
      "r" = "r";
      "s" = "s";
      "t" = "t";
      "u" = "u";
      "v" = "v";
      "w" = "w";
      "x" = "x";
      "y" = "y";
      "z" = "z";

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
