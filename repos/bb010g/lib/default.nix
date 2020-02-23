lib: libSuper:

let
  callLibs = name: file:
    libSuper.${name} // import file { lib = lib; libSuper = libSuper; };
in let exports = {

  ## modules

  attrsets = callLibs "attrsets" ./attrsets.nix;
  # edn = import ./edn;
  fixedPoints = callLibs "fixedPoints" ./fixed-points.nix;
  lists = callLibs "lists" ./lists.nix;
  trivial = callLibs "trivial" ./trivial.nix;
  # utf8 = import ./utf-8;

  ## top-level

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

}; in exports
