{ lib }:

let
  inherit (builtins) isString;
in

{
  /**
    Double const
  */
  const2 =
    a: b: c:
    a;

  /**
    Inverse of a boolean function
  */
  notf = f: n: !f n;

  /**
    The builtin function is deprecated, but it can still be useful in certain
    situations.
  */
  isNull = a: a == null;

  /**
    String join op
  */
  join = a: b: lib.throwIfNot (isString a && isString b) "Argument(s) not string: ${a} ${b}" a + b;
}
