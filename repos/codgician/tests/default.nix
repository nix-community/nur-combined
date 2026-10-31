# Top-level entry point for NUR tests.
#
# Mirrors the upstream nixpkgs convention of keeping NixOS VM tests in a
# dedicated tree (nixpkgs/nixos/tests/) rather than colocated next to the
# packages they exercise. Most `.nix` files in this directory are a single
# `pkgs.testers.runNixOSTest` definition; other test derivations (such as host
# unit-test suites) follow the same layout. This file collects them all into
# the `nurTests` attrset, the NUR-local equivalent of upstream's
# `pkgs.nixosTests`.
#
# Convention (matches nixpkgs):
#
#   - File name matches the package name (tests/<package-name>.nix).
#   - Attribute name in this set matches the package name.
#   - Packages reference their test as
#       `passthru.tests = { inherit (nurTests) <package-name>; };`
#     in the same shape `pkgs.nixosTests.<name>` is consumed in nixpkgs.
#
# Access paths:
#   - `nix build .#legacyPackages.<system>.tests.<name>` (this set)
#   - `nix build .#<name>.tests.<name>`                  (passthru)
#   - `nix build .#checks.<system>.<name>`               (flake check)
#   - `nix flake check`                                  (runs all)
#
# To add a test:
#   1. Drop `tests/<package-name>.nix` next to this file. Take whatever
#      NUR-internal packages you need as function arguments.
#   2. Register it below; tests of platform-restricted packages exist only
#      where the package does.
#   3. Wire it back from the package via `passthru.tests`.
#
# Each test then surfaces under flake `checks` and is built by CI.

{ pkgs }:

let
  nurPkgs = import ../pkgs { inherit pkgs; };
in
pkgs.lib.optionalAttrs (nurPkgs ? orion-o6-edk2) {
  orion-o6-edk2 = pkgs.callPackage ./orion-o6-edk2.nix { inherit (nurPkgs) orion-o6-edk2; };
}
