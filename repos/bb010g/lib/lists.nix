{ lib, libSuper ? lib }:

let
  inherit (lib.lists)
    foldl'
    foldl1' # (mod)
    head
    tail
  ;
in {

  foldl1' =
    f:
    xs:
    foldl' f (head xs) (tail xs);

}
