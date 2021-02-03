let
   inherit (builtins) head match readDir fromJSON filter replaceStrings attrNames listToAttrs genList;
   cwd = readDir ./.;
   overlays = filter (x: x != "default.nix" && cwd.${x} == "regular") (attrNames cwd);
   numlist = genList (x: toString x) 10;
   empties = genList (x: "") 10;
   format = filename: {
      priority = fromJSON (head ( match "([0-9]+)_.*" filename));
      function = import (./. + "/${filename}");
   };
in
   listToAttrs (map (x: { name = replaceStrings (numlist ++ [ "_" ".nix" ]) (empties ++ [ "" "" ]) x; value = format x; }) overlays)
