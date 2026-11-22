# A nixpkgs go_1_XX, updated to a newer patch release of its minor version.
#
# Bumping go in nixpkgs rebuilds every Go package, so it goes through staging
# and patch releases (mostly security fixes) take weeks to reach
# nixpkgs-unstable. Patch releases don't change nixpkgs' patches, so only the
# source is replaced.
#
# nixpkgs' go is used as is once it has caught up, so go is never downgraded.
# `pinned` always has the version from the version file, for update.sh.
{
  fetchurl,
  lib,

  # nixpkgs' go_1_XX, and the patch release of the same minor version
  go,
  version,
  hash,
}:

let
  minor = lib.versions.majorMinor version;
  attr = "go_${lib.replaceStrings [ "." ] [ "_" ] minor}-latest";

  pinned = go.overrideAttrs (
    finalAttrs: _: {
      inherit version;

      src = fetchurl {
        url = "https://go.dev/dl/go${finalAttrs.version}.src.tar.gz";
        inherit hash;
      };
    }
  );
in
assert lib.assertMsg (
  lib.versions.majorMinor go.version == minor
) "${attr}: go ${version} doesn't match nixpkgs' go ${go.version}";

(if lib.versionOlder go.version version then pinned else go).overrideAttrs (previousAttrs: {
  passthru = previousAttrs.passthru // {
    inherit pinned;

    updateScript = [
      "bash"
      "packages/go/update.sh"
      attr
    ];
  };
})
