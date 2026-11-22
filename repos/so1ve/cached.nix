# Upstream nixpkgs packages built by CI to populate cache.so1ve.dev
# (for example, unfree packages absent from cache.nixos.org).
{ lib, pkgs }:

{
  inherit (pkgs)
    lsfg-vk
    lsfg-vk-ui
    ;
}
// lib.optionalAttrs pkgs.stdenv.hostPlatform.isx86_64 {
  lsfg-vk-32 = pkgs.pkgsi686Linux.lsfg-vk;
}
