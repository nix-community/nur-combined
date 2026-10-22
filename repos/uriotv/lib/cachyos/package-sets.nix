# Convenience package sets for NixOS boot.kernelPackages, not derivations or CI roots.
# Do not inspect pkgs.stdenv here: this file runs inside the overlay fixpoint, and
# reading the platform from `final` recurses when NixOS evaluates kernelPackages.
# The kernels themselves carry meta.platforms = [ "x86_64-linux" ].
{
  pkgs,
  kernels,
}:
{
  linuxPackages-cachyos-latest-x86_64-v3 = pkgs.linuxPackagesFor kernels.linux-cachyos-latest-x86_64-v3;
  linuxPackages-cachyos-bore-x86_64-v3 = pkgs.linuxPackagesFor kernels.linux-cachyos-bore-x86_64-v3;
}
