# Placeholder committed so the package set evaluates before the update
# workflow regenerates this file with `crate2nix generate`
# (scripts/package-updates/update-lockfiles.nix treats a Cargo.nix
# without crate2nix's @generated header as stale and always regenerates
# it). Building it fails on purpose.
{pkgs, ...}: {
  workspaceMembers.wsrx.build = pkgs.runCommand "wsrx-placeholder" {meta = {};} ''
    echo "pkgs/wsrx/Cargo.nix is a placeholder; run the update workflow to regenerate it" >&2
    false
  '';
}
