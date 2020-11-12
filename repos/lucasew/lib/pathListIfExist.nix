# Input: a path
# Output: a list with the path if exists, empty list if it isn't exist
path:
let
  pathAsPath = /. + path;
  isExist = builtins.pathExists path;
in
if isExist then [pathAsPath] else []
