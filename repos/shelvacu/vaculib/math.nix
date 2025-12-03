{ lib, vaculib, ... }:
{
  # https://github.com/NixOS/nixpkgs/issues/41251#issuecomment-393660714
  pow =
    base: exponent:
    assert (builtins.isInt base) || (builtins.isFloat base);
    assert builtins.isInt exponent;
    if exponent > 0 then
      let
        and1 = x: (x / 2) * 2 != x;
        x = vaculib.pow base (exponent / 2);
      in
      x * x * (if and1 exponent then base else 1)
    else if exponent == 0 then
      1
    else
      throw "undefined";


  divrem =
    numerator: denominator:
    assert builtins.isInt numerator;
    assert builtins.isInt denominator;
    assert numerator >= 0;
    assert denominator > 0;
    {
      quotient = numerator / denominator;
      remainder = lib.mod numerator denominator;
    };
}
