{ ensureModules }:
let
   inherit (builtins) attrNames filter listToAttrs readDir replaceStringsWith;
   cwd = readDir ./.;
   srcs = filter (x: cwd.${x} == "directory") (attrNames cwd);
in
   listToAttrs (map (x: { name = x; value = ensureModules (./. + "/${x}/default.nix"); }) srcs)

