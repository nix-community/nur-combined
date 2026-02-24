{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  callPackage ? pkgs.callPackage,
}:

# The main packages
(lib.packagesFromDirectoryRecursive {
  directory = ./pkgs/by-name;
  callPackage = callPackage;
})
# Extras
// {

  lib = lib.foldr lib.mergeAttrs { } (
    map (x: import x { inherit pkgs; })
      # fileset
      (lib.filesystem.listFilesRecursive ./lib)
  );

  modules = lib.listToAttrs (
    map (x: {
      name = lib.removeSuffix ".nix" (baseNameOf x);
      value = x;
    }) (lib.filesystem.listFilesRecursive ./modules)
  );

  qemuImages = lib.recurseIntoAttrs (callPackage ./pkgs/qemu-images { });

  python3Packages = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      directory = ./pkgs/python3-packages;
      callPackage = pkgs.python3Packages.callPackage;
      newScope = pkgs.python3Packages.newScope;
    }
  );

  lispPackages = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      directory = ./pkgs/lisp-packages;
      callPackage = callPackage;
    }
  );

  emacsPackages = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      directory = ./pkgs/emacs-packages;
      callPackage = pkgs.emacs.pkgs.callPackage;
    }
  );
}
