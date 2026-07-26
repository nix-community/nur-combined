final: prev:
{
  linuxKernel = prev.linuxKernel // {
    packagesFor = kernel: (prev.linuxKernel.packagesFor kernel).extend (import ./linux-packages.nix);
  };
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [ (import ./python-packages.nix) ];
}
// prev.lib.concatMapAttrs (_: v: v) (
  prev.lib.packagesFromDirectoryRecursive {
    inherit (final) callPackage;
    directory = ../by-name;
  }
)
