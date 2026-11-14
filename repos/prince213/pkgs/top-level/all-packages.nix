final: prev:
{
  linuxKernel = prev.linuxKernel // {
    packagesFor = kernel: (prev.linuxKernel.packagesFor kernel).extend (import ./linux-packages.nix);
  };
  nixosTests =
    prev.nixosTests
    // import ../../nixos/tests/all-tests.nix {
      runTest =
        test:
        final.testers.runNixOSTest {
          imports = [ test ];
          node.pkgsReadOnly = false;
          defaults.nixpkgs.overlays = final.overlays;
        };
    };
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [ (import ./python-packages.nix) ];
}
// prev.lib.concatMapAttrs (_: v: v) (
  prev.lib.packagesFromDirectoryRecursive {
    inherit (final) callPackage;
    directory = ../by-name;
  }
)
