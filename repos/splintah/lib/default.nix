# My library functions. These functions are implemented using the
# __functor feature: any set with a __functor attribute will be
# callable. I use this fact to add a documentation string to the
# function, so that callers need not look up the source file for
# documentation, but can see it in their Nix REPL. See the Nix manual
# for more information about __functor.
{ lib }:
rec {
  attrsToList = {
    __functor = _self:
      with lib; mapAttrsToList nameValuePair;

    doc = ''
      Return a list of all name-value pairs in an attrs. Each pair has
      the form { name = <name>; value = <value>; }.

      Example:
        attrsToList { a = 1; b = 2; c = { d = 3; }; }
      =>
        [
          { name = "a"; value = 1; }
          { name = "b"; value = 2; }
          { name = "c"; value = { d = 3; }; }
        ]
    '';
  };

  flattenAttrs = {
    __functor = _self:
      attrs: with lib;
        concatLists (collect isList attrs);

    doc = ''
      Concatenates all lists in a nested attrs, ignoring the names and
      all non-list values.

      Example:
        flattenAttrs { a = [ 1 2 3 ]; b = { c = [ 4 5 6 ]; d = "hello"; }; }
      =>
        [ 1 2 3 4 5 6 ]
    '';
  };
}
