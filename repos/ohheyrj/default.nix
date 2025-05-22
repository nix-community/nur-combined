{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

let
  inherit (pkgs) lib stdenv;

  # Function to recursively find all default.nix files in pkgs/
  findPackages = dir:
    let
      contents = builtins.readDir dir;
      
      # Find all subdirectories
      subdirs = lib.filterAttrs (name: type: type == "directory") contents;
      
      # Check if current directory has a default.nix (making it a package)
      hasDefault = contents ? "default.nix";
      
      # Recursively search subdirectories
      subPackages = lib.concatMapAttrs (name: _: 
        findPackages (dir + "/${name}")
      ) subdirs;
      
    in
      if hasDefault then
        # This directory is a package - use just the directory name
        { ${baseNameOf (toString dir)} = dir; } // subPackages
      else
        # This directory is not a package, just return subdirectory results
        subPackages;

  # Discover all packages in pkgs/
  discoveredPackages = findPackages ./pkgs;

  # Function to safely get platforms from a package
  getPlatforms = name: path:
    let
      # Try to import and evaluate the package to get its meta.platforms
      tryEval = builtins.tryEval (
        let
          packageFn = import path;
          evalPkg = pkgs.callPackage packageFn {};
        in
          evalPkg.meta.platforms or []
      );
    in
      if tryEval.success then
        tryEval.value
      else
        # Fallback: if we can't evaluate, assume it's Darwin-only based on your current setup
        [ "x86_64-darwin" "aarch64-darwin" ];

  # Filter packages based on current platform
  compatiblePackages = lib.filterAttrs (name: path:
    let platforms = getPlatforms name path;
    in lib.elem stdenv.hostPlatform.system platforms
  ) discoveredPackages;

  # Build the compatible packages
  builtPackages = lib.mapAttrs (name: path:
    pkgs.callPackage path {}
  ) compatiblePackages;

in {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;
} // builtPackages
