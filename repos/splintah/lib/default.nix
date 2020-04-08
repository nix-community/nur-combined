{ lib }:
{
  /* Return a list of all name-value pairs in an attrs. Each pair has
     the form { name = <name>; value = <value>; }.

     Example:
       attrsToList { a = 1; b = 2; c = { d = 3; }; }
       => [
         { name = "a"; value = 1; }
         { name = "b"; value = 2; }
         { name = "c"; value = { d = 3; }; }
       ]
  */
  attrsToList = with lib; mapAttrsToList nameValuePair;

  /* Concatenates all lists in a nested attrs, ignoring the names and
     all non-list values.

     Example:
       flattenAttrs { a = [ 1 2 3 ]; b = { c = [ 4 5 6 ]; d = "hello"; }; }
       => [ 1 2 3 4 5 6 ]
  */
  flattenAttrs = attrs: with lib;
    concatLists (collect isList attrs);
}
