{ lib }: with lib; {
  types = {
    values = types.mkOptionType {
      name = "unmergedValues";
      merge = loc: defs: map (def: def.value) defs;
    };
    attrs = types.attrsOf unmerged.types.values;
  };
  type = unmerged.types.values;
  freeformType = unmerged.types.attrs;

  merge = mkMerge;
  mergeAttrs = mapAttrs (_: unmerged.merge);
}
