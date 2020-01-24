lib: libSuper:

let
  inherit (builtins)
    hasAttr
  ;
  inherit (lib.trivial)
    elemAt
    length
    functionArgs
  ;
  inherit (lib.attrsets)
    attrNames
    mapAttr # (mod)
    mapAttr' # (mod)
    mapAttrOr mapAttrOrElse # (mod)
    mapOptionalAttr # (mod)
    optionalAttrs
  ;
in {

  mapAttr =
    name:
    f:
    set:
    set // { ${name} = f set.${name}; };

  mapAttr' =
    f:
    let argNames = attrNames (functionArgs f); in
    assert length argNames == 1;
    let name = elemAt argNames 0; in
    set:
    set // { ${name} =
      f (optionalAttrs (hasAttr name set) { ${name} = set.${name}; }); };

  mapAttrOr =
    name:
    f:
    nul:
    set:
    if hasAttr name set
      then mapAttr name f set
      else nul;

  mapAttrOrElse =
    name:
    f:
    nulF:
    set:
    mapAttrOr name f (nulF name set) set;

  mapOptionalAttr =
    name:
    f:
    nul:
    set:
    set // { ${name} = f set.${name} or nul; };

}
