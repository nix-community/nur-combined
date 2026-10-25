# Package directories whose function takes `kernel` are out-of-tree kernel
# modules. Like pkgs/os-specific/linux/* in nixpkgs, they live in a
# linuxPackages scope (`kernel`, `kernelModuleMakeFlags`, the kernel's
# stdenv), so they are built against whichever kernel the consumer uses.
#
# This file only depends on builtins: overlays/ and modules/ import it
# without a `pkgs` instance.
let
  entries = builtins.readDir ./.;
  isKernelModule =
    name: entries.${name} == "directory" && builtins.functionArgs (import ./${name}) ? kernel;
in
rec {
  names = builtins.filter isKernelModule (builtins.attrNames entries);

  # A `kernelPackagesExtensions` entry adding every module to a linuxPackages
  # set. `kfinal.callPackage` binds `kernel` late, so NixOS's
  # `boot.kernelPatches` override of the kernel is honoured.
  extension =
    kfinal: _kprev:
    builtins.listToAttrs (
      map (name: {
        inherit name;
        value = kfinal.callPackage ./${name} { };
      }) names
    );
}
