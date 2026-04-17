{ self, inputs, ... }:
{
  flake.nixosModules =
    let
      genFilteredDirAttrs =
        dir: excludes:
        let
          inherit (inputs.nixpkgs.lib)
            genAttrs
            subtractLists
            removeSuffix
            attrNames
            filterAttrs
            ;
          inherit (builtins) readDir;
        in
        genAttrs (
          subtractLists excludes (
            map (removeSuffix ".nix") (attrNames (filterAttrs (_: v: v == "regular") (readDir dir)))
          )
        );

      shadowedModules = [ ];
      modules =
        let
          genModule = dir: genFilteredDirAttrs dir shadowedModules (n: import (dir + "/${n}.nix"));
        in
        (genModule ../nixosModules);

      default =
        { ... }:
        {
          imports = builtins.attrValues modules;
        };
    in
    modules // { inherit default; };

}
