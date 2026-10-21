# CachyOS Linux kernel, x86-64-v3, non-LTO, latest upstream line (master).
#
# Upstream is imported from a pinned source tree, not added as a flake input:
# pkgs/default.nix passes only `pkgs`, and the NUR/overlay exports must match the
# flake exports (tests/registry-eval.py). Upstream's own flake.lock and nixpkgs
# are used, so the derivation does not depend on any nixpkgs pinned by a consumer:
# laptop, desktop and CI get the same drvPath. Do not add nixpkgs.follows,
# overrideAttrs or another nixpkgs here: any of them changes the derivation.
{
  lib,
  fetchFromGitHub,
  # Arguments of kernel.override (e.g. from NixOS boot.kernelPackages: features,
  # kernelPatches, randstructSeed). callPackage replaces the upstream `override`
  # with this function's, so they arrive here and are forwarded to upstream.
  ...
}@args:
let
  # Only rev and hash are rewritten by update.py.
  upstream = fetchFromGitHub {
    owner = "xddxdd";
    repo = "nix-cachyos-kernel";
    rev = "893cfece885f2af90edc71fd0d8f95a83d72c7e2";
    hash = "sha256-SS3BBn0twL4iBphC7lSdA2lmXsL6HT/RrENC9OI3XZk=";
  };
  upstreamKernel = (import upstream).packages.x86_64-linux.linux-cachyos-latest-x86_64-v3;
  overrides = removeAttrs args [
    "lib"
    "fetchFromGitHub"
  ];
  # Without overrides the upstream derivation is returned unchanged (same drvPath
  # as kernel.yml builds). kernelPatches are appended to upstream's CachyOS
  # patches, never replace them: overrides only ever see this function's original
  # arguments, which do not contain upstream's patch list.
  kernel =
    if overrides == { } then
      upstreamKernel
    else
      upstreamKernel.override (
        original:
        overrides
        // {
          kernelPatches = (original.kernelPatches or [ ]) ++ (overrides.kernelPatches or [ ]);
        }
      );
in
# addMetaAttrs changes only meta, which is not part of the derivation hash.
lib.addMetaAttrs {
  # Built by .github/workflows/kernel.yml on the self-hosted builder, not by build.yml.
  ciBuild = false;
  description = "Linux CachyOS kernel for x86-64-v3 (non-LTO), from xddxdd/nix-cachyos-kernel";
  homepage = "https://github.com/xddxdd/nix-cachyos-kernel";
  license = lib.licenses.gpl2Only; # GPL-2.0-only, redistributable
  platforms = [ "x86_64-linux" ];
} kernel
