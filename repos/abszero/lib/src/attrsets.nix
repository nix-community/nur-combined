{ super, lib }:

let
  inherit (lib)
    collect
    filterAttrs
    zipAttrsWith
    last
    ;
  inherit (builtins)
    isAttrs
    isList
    attrNames
    attrValues
    all
    head
    concatLists
    ;
  inherit (super.trivial) notf;
in

rec {
  /**
    Recursively collects all values.
  */
  attrValuesRecursive = collect (notf isAttrs);

  /**
    Recursively merge attribute sets and lists.
    This assumes that overriden options are of the same type.
  */
  recursiveMerge = zipAttrsWith (
    _: vs:
    if all isAttrs vs then
      recursiveMerge vs
    else if all isList vs then
      concatLists vs
    else
      last vs
  );

  /**
    Find the first attribute verified by the predicate and return the name.
  */
  findName = pred: attrs: head (attrNames (filterAttrs pred attrs));
  /**
    Find the first attribute verified by the predicate and return the value.
  */
  findValue = pred: attrs: head (attrValues (filterAttrs pred attrs));
}
