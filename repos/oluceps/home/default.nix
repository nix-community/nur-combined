{
  lib,
  pkgs,
  user,
  ...
}@args:
# https://gist.github.com/thalesmg/ae5dc3c5359aed78a33243add14a887d
let
  configPlace = "/home/${user}/.config";

  inherit (builtins) readDir foldl' attrNames;
  inherit (lib.attrsets) filterAttrs setAttrByPath recursiveUpdate;
  inherit (lib) removeSuffix;
  inherit (pkgs) writeText;

  listRecursive = pathStr: listRecursive' { } pathStr;
  listRecursive' =
    acc: pathStr:
    let
      toPath = s: path + "/${s}";
      path = ./. + pathStr;
      contents = readDir path;
      dirs = filterAttrs (k: v: v == "directory") contents;
      files = filterAttrs (k: v: v == "regular" && k != "default.nix") contents;
      dirs' = foldl' (acc: d: recursiveUpdate acc (listRecursive (pathStr + "/" + d))) { } (
        attrNames dirs
      );
      files' = foldl' (
        acc: f:
        recursiveUpdate acc (
          setAttrByPath [ "${configPlace}${pathStr}/${(removeSuffix ".nix" f)}" ] (
            if lib.hasSuffix ".nix" f then
              (writeText (removeSuffix ".nix" f) (import (/. + f) args))
            else
              /. + f
          )
        )
      ) { } (attrNames files);
    in
    recursiveUpdate dirs' files';
in
listRecursive ""
