{ lib, ... }:

rec {
  /* abs :: int -> int[>= 0]
   *
   * Returns the absolute (unsigned) value of n.
   */
  abs = n:
    if n >= 0
    then n
    else n * (-1);

  /* pow :: int -> int[> 0] -> int[]
   *
   * Exponentiation operator, computes n to the e-th (non-negative)
   * power.
   */
  pow = n: e:
    let
      result =
        if e == 0 then 1
        else if e == 1 then n
        else n * (pow n (e - 1));
    in
    assert e >= 0;
    assert e > 0 -> (abs result) >= (abs n);
    result;

  /* rem :: int -> int -> int
   *
   * Computes the remainder of the division of `n` by `d`, such that
   * `rem n d == n - (n / d) * d`.  The sign of the result is that of
   * the dividend `n`.
   */
  rem = n: d: n - d * (n / d);
}
