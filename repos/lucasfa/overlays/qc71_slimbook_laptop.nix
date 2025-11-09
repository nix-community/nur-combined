final: prev:
let
  lib = prev.lib;
in
{
  linuxKernel = prev.linuxKernel // {
    # don't update since most of these come from  nixpkgs
    updateWithSuper = false;

    packagesFor =
      kernel:
      (prev.linuxKernel.packagesFor kernel).extend (
        kFinal: kPrev:
        (lib.filesystem.packagesFromDirectoryRecursive {
          inherit (kFinal) callPackage;
          directory = ../pkgs/linux-packages;
        })
      );
  };

  # Bring up the packages to the top-level
  inherit
    (lib.filesystem.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ../pkgs/linux-packages;
    })
    ;
}
