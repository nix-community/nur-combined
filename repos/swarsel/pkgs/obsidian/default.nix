  { nixlib, pkgs, ... }:
  let
    lib = nixlib;
    mkPackages = names: pkgs: builtins.listToAttrs (map
      (name: {
        # name = "obsidianPackages.${name}";
        inherit name;
        value = pkgs.callPackage ./${name} { inherit lib name; };
      })
      names);
    readNix = nixlib.filter (name: name != "default.nix") (nixlib.attrNames (builtins.readDir ./. ));
  in
  mkPackages readNix pkgs
