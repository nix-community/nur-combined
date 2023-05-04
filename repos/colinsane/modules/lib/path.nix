{ lib, ... }:

let path = rec {

  # split the string path into a list of string components.
  # root directory "/" becomes the empty list [].
  # implicitly performs normalization so that:
  # split "a//b/" => ["a" "b"]
  # split "/a/b" =>  ["a" "b"]
  split = str: builtins.filter (seg: seg != "") (lib.splitString "/" str);
  # given an array of components, returns the equivalent string path
  join = comps: "/" + (builtins.concatStringsSep "/" comps);
  # given an a sequence of string paths, concatenates them into one long string path
  concat = paths: path.join (builtins.concatLists (builtins.map path.split paths));
  # normalize the given path
  norm = str: path.join (path.split str);
  # return the parent directory. doesn't care about leading/trailing slashes.
  # the parent of "/" is "/".
  parent = str: path.norm (builtins.dirOf (path.norm str));
  hasParent = str: (path.parent str) != (path.norm str);
  # return the path from `from` to `to`, but keeping absolute form
  # e.g. `pathFrom "/home/colin" "/home/colin/foo/bar"` -> "/foo/bar"

  # return the last path component; error on the empty path
  leaf = str: lib.last (split str);

  from = start: end: let
    s = path.norm start;
    e = path.norm end;
  in (
    assert lib.hasPrefix s e;
    "/" +  (lib.removePrefix s e)
  );

  # yield every node between start and end, including each the endpoints
  # e.g. walk "/foo" "/foo/bar/baz" => [ "/foo" "/foo/bar" "/foo/bar/baz" ]
  # XXX: assumes input paths are normalized
  walk = start: end: if start == end then
    [ start ]
  else
    (walk start (parent end)) ++ [ end ]
  ;
};
in path
