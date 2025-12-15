{ pkgs }:

with pkgs.lib;
let
  lib = pkgs.lib;
in
{
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};

  # the commit before https://github.com/NixOS/nixpkgs/commit/2dbc1128b3d1b2a80eb62607bf21f0f94f9b2d5f
  zfs-latestCompatibleLinuxPackages = lib.pipe pkgs.linuxKernel.packages [
    builtins.attrValues
    (builtins.filter (
      kPkgs:
      (builtins.tryEval kPkgs).success
      && kPkgs ? kernel
      && kPkgs.kernel.pname == "linux"
      && kPkgs.${pkgs.zfs.kernelModuleAttribute}.meta.broken != true
    ))
    (builtins.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)))
    lib.last
  ];
  zfs_unstable-latestCompatibleLinuxPackages = lib.pipe pkgs.linuxKernel.packages [
    builtins.attrValues
    (builtins.filter (
      kPkgs:
      (builtins.tryEval kPkgs).success
      && kPkgs ? kernel
      && kPkgs.kernel.pname == "linux"
      && kPkgs.${pkgs.zfs_unstable.kernelModuleAttribute}.meta.broken != true
    ))
    (builtins.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)))
    lib.last
  ];
}
