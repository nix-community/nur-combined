{ lib, ... }:
rec {
  mkOutOption =
    val:
    lib.mkOption {
      readOnly = true;
      default = val;
      defaultText = "(final/output of module)";
    };

  mkOutOptions = attrs: builtins.mapAttrs (_: v: mkOutOption v) attrs;
}
