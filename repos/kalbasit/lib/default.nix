{ pkgs }:

with pkgs;
with lib;

{
  recCallPackage = dir:
    let content = builtins.readDir dir; in
      builtins.listToAttrs
        (map (n: {name = n; value = callPackage (dir + ("/" + n)) {}; })
        (builtins.filter (n: builtins.pathExists (dir + ("/" + n + "/default.nix")))
          (builtins.attrNames content)));
}
