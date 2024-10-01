{
  pkgs,
  lib,
  mode,
}:
rec {
  # Wrapper will greatly increase NUR evaluation time. Disable on NUR to stay within 15s time limit.
  mergePkgs = pkgs.callPackage ./merge-pkgs.nix {
    enableWrapper =
      !(builtins.elem mode [
        "nur"
        "legacy"
      ]);
  };

  ifNotCI = p: if mode == "ci" then null else p;
  ifNotNUR = p: if mode == "nur" then null else p;

  nvfetcherLoader = pkgs.callPackage ./nvfetcher-loader.nix { };
  sources = nvfetcherLoader ../_sources/generated.nix;

  createCallPackage =
    _packages:
    lib.callPackageWith (
      pkgs
      // _packages
      // {
        inherit
          _packages
          sources
          ;
        kernel = pkgs.linux;
      }
    );

  createCallGroupDeps =
    _packages: callPackage:
    let
      loadPackages =
        path: mapping:
        lib.genAttrs
          (builtins.filter (v: !(lib.hasSuffix ".nix" v)) (builtins.attrNames (builtins.readDir path)))
          (
            n:
            let
              pkg = callPackage (path + "/${n}") { };
            in
            (mapping."${n}" or (v: v)) pkg
          );
    in
    {
      inherit
        _packages
        callPackage
        ifNotCI
        ifNotNUR
        loadPackages
        mergePkgs
        mode
        sources
        ;
    };

  createCallGroup =
    _packages: callPackage: path:
    pkgs.callPackage path (createCallGroupDeps _packages callPackage);

  createLoadPackages =
    callPackage: path: mapping:
    lib.genAttrs
      (builtins.filter (v: !(lib.hasSuffix ".nix" v)) (builtins.attrNames (builtins.readDir path)))
      (
        n:
        let
          pkg = callPackage (path + "/${n}") { };
        in
        (mapping."${n}" or (v: v)) pkg
      );

  _doGroupPackages =
    callGroup: groups: lib.mapAttrs (_n: callGroup) (lib.filterAttrs (_n: v: v != null) groups);

  doFlatGroupPackages =
    _packages: groups:
    let
      callPackage = createCallPackage _packages;
      callGroupDeps = createCallGroupDeps _packages callPackage;
      callGroup = p: import p callGroupDeps;
    in
    _doGroupPackages callGroup groups;

  doGroupPackages =
    _packages: groups:
    let
      callPackage = createCallPackage _packages;
      callGroup = createCallGroup _packages callPackage;
    in
    _doGroupPackages callGroup groups;

  doMergePkgs = lib.mapAttrs (_n: v: if lib.isDerivation v then v else mergePkgs v);
}
