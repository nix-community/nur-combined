# go-latest: the go_1_XX-latest for the minor version of nixpkgs' go_latest.
#
# Without a version file for it (e.g. after nixpkgs moves to a new minor
# version), it's nixpkgs' go_latest. Only that version file is evaluated, so
# version files for go releases nixpkgs no longer has don't break it.
#
# go_1_XX-latest updates its version file, so the update script is removed
# here to avoid updating it twice.
{
  callPackage,
  go_latest,
  lib,
}:

let
  file = ./. + "/${lib.versions.majorMinor go_latest.version}.nix";
  go = if builtins.pathExists file then callPackage file { } else go_latest;
in
go.overrideAttrs (previousAttrs: {
  passthru = removeAttrs previousAttrs.passthru [ "updateScript" ];
})
