lib: libSuper:

let
  inherit (builtins) getAttr hasAttr mapAttrs;
  mergeModule = name: module:
    if hasAttr name libSuper then
      (getAttr name libSuper) // module
    else module;
  callLib = file: import file lib libSuper;
in let modules = {

  attrsets = callLib ./attrsets.nix;
  # edn = import ./edn;
  fixedPoints = callLib ./fixed-points.nix;
  lists = callLib ./lists.nix;
  trivial = callLib ./trivial.nix;
  # utf8 = import ./utf-8;

}; in (mapAttrs mergeModule modules) // {

  inherit (lib.attrsets)
    mapAttr
    mapAttr'
    mapAttrOr mapAttrOrElse
    mapOptionalAttr
  ;

  inherit (lib.fixedPoints)
    composeExtensionList
  ;

  inherit (lib.lists)
    foldl1'
  ;

  inherit (lib.trivial)
    apply applyOp
    comp compOp flow
    comp2 comp2Op flow2
    comp3 comp3Op flow3
    hideFunctionArgs
    mapFunctionArgs
    mapIf
  ;

}
