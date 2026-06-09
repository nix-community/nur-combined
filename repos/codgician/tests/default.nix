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

# No NixOS VM tests are currently registered, so this set is empty and the
# `{ inherit pkgs; }` argument from callers is ignored. To add a test, drop
# `tests/<package>.nix` next to this file, switch the signature back to
# `{ pkgs }:`, and register it as:
#
#   let nurPkgs = import ../pkgs { inherit pkgs; };
#   in { <name> = pkgs.callPackage ./<name>.nix { inherit (nurPkgs) <name>; }; }
#
# Each test then surfaces under flake `checks` and is built by CI.

{ ... }:

{ }
