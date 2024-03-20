{ pkgs
, lib
}:
let
  inherit (pkgs.lib) filterAttrs;
  inherit (pkgs.lib.attrsets) mapAttrs;
  inherit (pkgs.lib.lists) foldl elem;
  inherit (pkgs.lib.strings) hasPrefix;
  inherit (builtins) readDir pathExists attrNames isAttrs;
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

  attrsets = rec {
    # utility function to tell what changed between two attrsets
    # useful for wrapping your head around certain aspects of self-referential lazyness.
    # example: pkgs.lib.attrsets.diff npkgs.openssl.bin npkgs.openssl.dev
    diff = a: b: foldl
      (x: y: x // y) { }
      (map
        # yes, parenthesizing a and b is needed.
        (name: let aa = (a)."${name}" or null;
                   bb = (b)."${name}" or null;
               in
                 if aa == bb
                 then { }
                 else { "${name}" =
                          (if isAttrs aa && isAttrs bb
                           then diff aa bb
                           else bb); })
        (attrNames (a // b)));
    # filter an attrset so it only has keys starting with `pre`
    withPrefix = pre: filterAttrs (name: _: hasPrefix pre name);
  };

  #lists.uniqueLazy = foldl (acc: e: if elem e acc then acc else acc ++ [ e ]) [];
  testers = pkgs.callPackage ./test { inherit lib; };
}
