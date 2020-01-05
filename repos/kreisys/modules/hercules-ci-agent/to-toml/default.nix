{ lib }:
let
  inherit (lib)
    concatStrings
    mapAttrsToList
    ;
  inherit (builtins)
    abort
    match
    toJSON
    typeOf
    ;

  quoteKey = k:
    if match "[a-zA-Z]+" k == []
    then k
    else quoteString k;

  quoteString = builtins.toJSON;

in
{
  toTOML = attrs:
    if typeOf attrs != "set"
    then abort "toTOML needs an attribute set"
    else let
      sectionContents = p: attrs:
        concatStrings (
          mapAttrsToList (
            k: v:
              if typeOf v == "string"
              then "${quoteKey k} = ${quoteString v}\n"
              else if typeOf v == "bool"
              then "${quoteKey k} = ${toJSON v}\n"
              else if typeOf v == "int"
              then "${quoteKey k} = ${toJSON v}\n"
              else if typeOf v == "float"
              then abort "toTOML: ${k}: float not implemented yet"
              else if typeOf v == "list"
              then abort "toTOML: ${k}: list not implemented yet"
              else if typeOf v == "set"
              then abort "toTOML: ${k}: nested set / tables not implemented yet"
              else abort "toTOML: ${k}: type ${typeOf v} not supported"
          ) attrs
        );
    in
      sectionContents [] attrs;
}
