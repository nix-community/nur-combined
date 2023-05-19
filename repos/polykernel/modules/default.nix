let
  genModuleTree' = depth: mods:
    let
      prefixAttrs = builtins.groupBy (p: builtins.elemAt p depth) (builtins.filter (p: builtins.length p > depth) mods);
    in (builtins.mapAttrs (
      _: v:
      let
        repr = builtins.head v;
      in
      if builtins.length repr == depth + 1
      then ./. + "/${builtins.concatStringsSep "/" repr}.nix"
      else genModuleTree' (depth + 1) v
    )
    prefixAttrs);

  genModuleTree = genModuleTree' 0;

  hmModules = [
    [ "programs" "swayimg" ]
    [ "programs" "kickoff" ]
  ];
  nixosModules = [ ];
in {
  hm = genModuleTree hmModules;
  nixos = genModuleTree nixosModules;
}
