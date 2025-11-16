final: prev:
{
  linuxKernel = prev.linuxKernel // {
    # don't update since most of these come from  nixpkgs
    updateWithSuper = false;

    packagesFor =
      kernel:
      (prev.linuxKernel.packagesFor kernel).extend (
        kFinal: kPrev:
        (final.lib.filesystem.packagesFromDirectoryRecursive {
          inherit (kFinal) callPackage;
          directory = ../pkgs/linux-packages;
        })
      );
  };

  # Bring up the packages to the top-level
  inherit
    (final.lib.filesystem.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ../pkgs/linux-packages;
    })
    ;
}
