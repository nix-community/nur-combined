{ lib, libSuper }:

let
  # lib imports {{{1
  inherit (builtins) #{{{2
    hasAttr
  ;
  inherit (lib.trivial) #{{{2
    elemAt
    length
    functionArgs
  ;

  inherit (lib.attrsets) #{{{1
    attrNames
    mapAttr # (mod)
    mapAttr' # (mod)
    mapAttrOr mapAttrOrElse # (mod)
    mapOptionalAttr # (mod)
    optionalAttrs
  ; #}}}1
in {

  # mapAttr {{{2
  mapAttr =
    name:
    f:
    set:
    set // { ${name} = f set.${name}; };

  # mapAttr' {{{2
  mapAttr' =
    f:
    let argNames = attrNames (functionArgs f); in
    assert length argNames == 1;
    let name = elemAt argNames 0; in
    set:
    set // { ${name} =
      f (optionalAttrs (hasAttr name set) { ${name} = set.${name}; }); };

  # mapAttrOr [mapAttrOrElse] {{{2
  mapAttrOr =
    name:
    f:
    nul:
    set:
    if hasAttr name set
      then mapAttr name f set
      else nul;

  # mapAttrOrElse {{{3
  mapAttrOrElse =
    name:
    f:
    nulF:
    set:
    mapAttrOr name f (nulF name set) set;

  # mapOptionalAttr {{{2
  mapOptionalAttr =
    name:
    f:
    nul:
    set:
    set // { ${name} = f set.${name} or nul; };

  #}}}1

}
# vim:fdm=marker:fdl=1
