{ lib, mkLapcePlugin }:

let
  hashes = builtins.fromJSON (builtins.readFile ./hashes.json);
in

builtins.foldl' (
  result: plugin:
  let
    cleanString = builtins.replaceStrings [ " " ] [ "-" ];
    author = lib.toLower (cleanString plugin.author);
    name = lib.toLower (cleanString plugin.name);
    hashKey = "lapce-plugin-${cleanString plugin.author}-${cleanString plugin.name}-${plugin.version}.volt";
    hash = hashes.${hashKey} or null;
  in
  result
  // lib.optionalAttrs (hash != null) {
    ${author} = (result.${author} or (lib.recurseIntoAttrs { })) // {
      ${name} = mkLapcePlugin (plugin // { inherit hash; });
    };
  }
) { } (builtins.fromJSON (builtins.readFile ./plugins.json))
