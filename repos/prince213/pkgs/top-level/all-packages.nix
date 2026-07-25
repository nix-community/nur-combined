final: prev:
{
  linuxKernel = prev.linuxKernel // {
    packagesFor = kernel: (prev.linuxKernel.packagesFor kernel).extend (import ./linux-packages.nix);
  };
}
// prev.lib.packagesFromDirectoryRecursive {
  inherit (final) callPackage;
  directory = ../by-name;
}
