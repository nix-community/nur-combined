{callPackage, ...}: {
  packages =
    {
      cosevka = callPackage ./cosevka {};
      lib = (callPackage ./lib/lib.nix {}).lib;
      terminus-font-custom = callPackage ./terminus-font-custom {};
      virt-manager = callPackage ./virt-manager {};
    }
    // (callPackage ./mozilla-langpack/packages.nix {}).packages;
}
