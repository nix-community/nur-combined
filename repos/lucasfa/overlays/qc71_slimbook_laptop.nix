final: prev:
let
  lib = prev.lib;
in
{
  linuxKernel = prev.linuxKernel // {
    # don't update by default since most of these packages are from a different repo (i.e. nixpkgs).
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

  inherit
    (lib.filesystem.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ../pkgs/linux-packages;
    })
    ;
}
