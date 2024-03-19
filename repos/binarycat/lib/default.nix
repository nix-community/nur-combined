{ pkgs
, lib ? pkgs.lib
}:
let
  inherit (lib.attrsets) mapAttrs;
  inherit (builtins) readDir pathExists;
  #dirToPkgs = name: type:
in {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  callDir = basePath: extraArgs: mapAttrs
    (name: type:
      let
        pkgPath = basePath + "/${name}/package.nix";
      in
        (if type == "directory" && pathExists pkgPath
         then builtins.trace "package found: ${pkgPath}" (pkgs.callPackage pkgPath extraArgs)
         else {}))
    (readDir basePath);
}
