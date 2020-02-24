import ./default-boilerplate.nix {
  modules = {
    attrsets = import ./attrsets.nix;
    # edn = import ./edn;
    fixedPoints = import ./fixed-points.nix;
    lists = import ./lists.nix;
    trivial = import ./trivial.nix;
    # utf8 = import ./utf-8;
  };
  reexports = { lib, libSuper }: {
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
  };
}
