{
  pkgs,
  lib,
  mode,
  inputs,
}:
rec {
  ifNotCI = p: if mode == "ci" then null else p;
  ifNotNUR = p: if mode == "nur" then null else p;

  nvfetcherLoader = pkgs.callPackage ./nvfetcher-loader.nix { };
  sources = nvfetcherLoader ../_sources/generated.nix;

  createCallPackage =
    _packages:
    lib.callPackageWith (
      pkgs
      // _packages
      // rec {
        inherit
          _packages
          sources
          inputs
          ;
        kernel = pkgs.linux;
        # Integrate to nixpkgs python3Packages
        python = pkgs.python.override { packageOverrides = final: prev: _packages.python3Packages; };
        python3 = pkgs.python3.override { packageOverrides = final: prev: _packages.python3Packages; };
        python3Packages = python3.pkgs;
      }
    );

  createCallGroupDeps =
    _packages: callPackage:
    let
      loadPackages = createLoadPackages callPackage;
    in
    {
      inherit
        # keep-sorted start
        _packages
        callPackage
        createCallPackage
        createLoadPackages
        ifNotCI
        ifNotNUR
        inputs
        lib
        loadPackages
        mode
        pkgs
        sources
        # keep-sorted end
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
    callGroup: groups: lib.mapAttrs (n: callGroup) (lib.filterAttrs (n: v: v != null) groups);

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
}
