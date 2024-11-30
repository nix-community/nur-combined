{ lib, mkLapcePlugin }:

builtins.foldl' (
  result: plugin:
  let
    cleanString = s: lib.toLower (builtins.replaceStrings [ " " ] [ "-" ] s);
    author = cleanString plugin.author;
    name = cleanString plugin.name;
  in
  result
  // {
    ${author} = (result.${author} or (lib.recurseIntoAttrs { })) // {
      ${name} = mkLapcePlugin plugin;
    };
  }
) { } (builtins.fromJSON (builtins.readFile ./plugins.json))
