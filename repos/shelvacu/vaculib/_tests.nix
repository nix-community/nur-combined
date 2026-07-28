{ lib, vaculib, ... }:
let
  allId = builtins.all (x: x);
  escapeNixPath =
    path:
    lib.pipe path [
      (map lib.strings.escapeNixIdentifier)
      (lib.concatStringsSep ".")
    ];
  allGoodImpl =
    path: val:
    if builtins.isBool val then
      (if val then true else throw "${escapeNixPath path}: test returned false")
    else if builtins.isAttrs val then
      lib.pipe val [
        (builtins.mapAttrs (k: v: allGood (path ++ [ k ]) v))
        builtins.attrValues
        allId
      ]
    else if builtins.isList val then
      lib.pipe val [
        (lib.imap0 (
          i: v:
          allGood (
            path
            ++ [
              toString
              i
            ]
          ) v
        ))
        allId
      ]
    else if builtins.isString val then
      throw "${escapeNixPath path}: ${val}"
    else
      throw "${escapeNixPath path}: bad val type ${builtins.typeOf val}";
  allGood =
    path: val: builtins.addErrorContext "while evaluating ${escapeNixPath path}" (allGoodImpl path val);
in
{
  allTestsGood = lib.pipe vaculib._unmerged [
    (builtins.mapAttrs (
      name: vaculibModule:
      if vaculibModule ? "_tests" then
        allGood [ "vaculib" "_unmerged" name "_tests" ] vaculibModule._tests
      else
        true
    ))
    builtins.attrValues
    allId
  ];
}
