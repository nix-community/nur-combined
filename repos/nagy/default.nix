{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  callPackage ? pkgs.callPackage,
}:

# The main packages
(lib.removeAttrs
  (lib.packagesFromDirectoryRecursive {
    directory = ./pkgs/by-name;
    callPackage = callPackage;
  })
  [
    # currently broken in nixpkgs upstream due to missing `homepage` and `longDescription` meta attributes.
    "quake3-wrapped"
  ]
)
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

  qemuImages = lib.recurseIntoAttrs (callPackage ./pkgs/qemu-images { });

  python3Packages = lib.makeScope pkgs.python3Packages.newScope (
    self:
    lib.recurseIntoAttrs (
      (lib.packagesFromDirectoryRecursive {
        directory = ./pkgs/python3-packages;
        callPackage = self.callPackage;
      })
    )
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
