{ lib, libSuper }:

let
  # lib imports {{{1
  inherit (lib.lists) #{{{1
    foldl'
    foldl1' # (mod)
    head
    tail
  ; #}}}1
in {

  # foldl1' {{{2
  foldl1' =
    f:
    xs:
    foldl' f (head xs) (tail xs);

  #}}}1

}
# vim:fdm=marker:fdl=1
