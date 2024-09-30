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

  createCallGroup =
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
    path:
    pkgs.callPackage path {
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

  doGroupPackages =
    _packages: groups:
    let
      callPackage = createCallPackage _packages;
      callGroup = createCallGroup _packages callPackage;
    in
    lib.mapAttrs (_n: v: callGroup v) (lib.filterAttrs (_n: v: v != null) groups);

  doMergePkgs = lib.mapAttrs (_n: v: if lib.isDerivation v then v else mergePkgs v);
}
