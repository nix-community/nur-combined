self: super: with super.lib; let
  lib = super.lib.extend (import ./lib);
  filterBlacklist = key: (all (p: p != key) [ "lib" "extend" "__unfix__" ]);
  filterPkgs = fn: (makeExtensible (_: { inherit (self) lib; })).extend (self: super: fn { inherit self super; inherit (super) lib; });
  filterPackageKeys = filterPkgs (import ./pkgs/instantiate.nix);
  filterBuildSupportKeys = filterPkgs (import ./build-support);
  filterLibKeys = makeExtensible (self: import ./lib self { });
  # TODO: assertions to check that we're not unknowingly overriding anything in pkgs?
  filtered = keys: pkgs: filterAttrs (key: _: let
      topAllowed = filterBlacklist key && (
        keys ? ${key}
      );
    in topAllowed
  ) pkgs;
  packages' = filtered filterPackageKeys self;
  # hacky, do this properly sometime...
  subpackages = filterAttrs (_: p: ! isDerivation p) packages';
  subpackages' = mapAttrs (k: p: filtered filterPackageKeys.${k} p) subpackages;
  packages'' = packages' // subpackages';
  arc = rec {
    pkgs = self;
    packages = builtins.removeAttrs packages'' [ "shells" "pythonInterpreters" "fetchurl" "mkShell" ];
    build = filtered filterBuildSupportKeys self;
    lib = filtered filterLibKeys self.lib;
    inherit (packages'') shells;
  } // import ./static.nix;
in {
  inherit arc lib;
} // (import ./pkgs/instantiate.nix { inherit self super lib; })
// (import ./build-support { inherit self super lib; })
