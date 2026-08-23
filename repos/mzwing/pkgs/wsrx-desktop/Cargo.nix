# Placeholder crate graph: keeps evaluation working until `nix run .#update-lockfiles` writes the real one.
# The update pipeline replaces any Cargo.nix without the crate2nix header, so this file is never committed twice.
{
  pkgs,
  buildRustCrateForPkgs ? null,
  defaultCrateOverrides ? null,
  ...
}: {
  workspaceMembers."wsrx-desktop".build =
    pkgs.runCommand "wsrx-desktop-unresolved" {
      # `overrideAttrs` in the package definition reads this.
      meta = {};
    } ''
      echo "pkgs/wsrx-desktop/Cargo.nix is a placeholder; run 'nix run .#update-lockfiles -- wsrx-desktop' first" >&2
      exit 1
    '';
}
