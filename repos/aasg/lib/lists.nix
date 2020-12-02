{ ... }:

rec {
  /* Return the index of the first element equal to `x` in the list
   * `xs`.
   *
   * Example:
   *     indexOf "c" ["a" "b" "c" "d" "e"]
   *     => 2
   *
   *     indexOf "g" ["a" "b" "c" "d" "e"]
   *     => -1
   */
  indexOf = x: xs:
    let indexOfRec = i: xs:
      if xs == [ ] then -1
      else if (builtins.head xs) == x then i
      else indexOfRec (i + 1) (builtins.tail xs);
    in indexOfRec 0 xs;

  /* Test if $ys ⊆ xs$, that is, if every element of the list `ys` is
   * also in `xs`.
   *
   * Example:
   *     isSubsetOf [1 2 3 4 5] [1 3 5]
   *     => true
   */
  isSubsetOf = xs: ys:
    builtins.all (y: builtins.elem y xs) ys;
}
