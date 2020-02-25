{ lib, libSuper }:

let
  # lib imports {{{1
  inherit (lib.trivial) #{{{1
    id
    mapIf # (mod)
  ; #}}}1
in {

  # mapIf {{{2
  /* Apply function if the second argument is true.

     Type: mapIf :: (a -> a) -> bool -> a -> a

     Example:
       mapIf (x: x+1) false 9
       => 9
       mapIf (x: x+1) true 9
       => 10
  */
  mapIf =
    # Function to call
    f:
    # Boolean to test
    b:
    if b then f else id;

  #}}}1

}
# vim:fdm=marker:fdl=1
