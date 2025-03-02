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

  modules =
    (lib.packagesFromDirectoryRecursive {
      directory = ./modules;
      callPackage = (x: _a: import x);
    })
    // {
      all = {
        imports = lib.filesystem.listFilesRecursive ./modules;
      };
    };

  qemuImages = pkgs.recurseIntoAttrs (callPackage ./pkgs/qemu-images { });

  python3Packages = lib.makeScope pkgs.python3Packages.newScope (
    self:
    pkgs.recurseIntoAttrs (
      (lib.packagesFromDirectoryRecursive {
        directory = ./pkgs/python3-packages;
        callPackage = self.callPackage;
      })
    )
  );

  lispPackages = pkgs.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      directory = ./pkgs/lisp-packages;
      callPackage = callPackage;
    }
  );

  emacsPackages = pkgs.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      directory = ./pkgs/emacs-packages;
      callPackage = pkgs.emacs.pkgs.callPackage;
    }
  );
}
