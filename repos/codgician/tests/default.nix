# Top-level entry point for NUR NixOS VM tests.
#
# Mirrors the upstream nixpkgs convention of keeping NixOS VM tests in a
# dedicated tree (nixpkgs/nixos/tests/) rather than colocated next to the
# packages they exercise. Each `.nix` file in this directory is a single
# `pkgs.testers.runNixOSTest` definition; this file collects them all into
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
#   - `nix build .#legacyPackages.<system>.tests.litellm`     (this set)
#   - `nix build .#litellm.tests.litellm`                     (passthru)
#   - `nix build .#checks.<system>.litellm`                   (flake check)
#   - `nix flake check`                                       (runs all)
#
# To add a new test:
#   1. Drop `tests/<package-name>.nix` next to this file. Take whatever
#      NUR-internal packages you need as function arguments (see
#      tests/litellm.nix as an example).
#   2. Register it below.
#   3. Wire it back from the package via `passthru.tests`.

{ pkgs }:

let
  # NUR packages and their internal helpers, made available to tests via
  # `pkgs.callPackage`. We use `nurPkgs` (the result of `pkgs/default.nix`)
  # rather than re-`callPackage`-ing each derivation here, so each test
  # sees the exact same closure the user-facing `pkgs.<name>` uses.
  nurPkgs = import ../pkgs { inherit pkgs; };
in

{
  litellm = pkgs.callPackage ./litellm.nix {
    inherit (nurPkgs) litellm;
    inherit (nurPkgs.litellm.passthru) prisma-engines;
  };
}
