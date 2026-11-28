{
  lib,
  diffoscope,
  fetchpatch,
}:

let
  # Fix `ValueError: too many values to unpack (expected 3, got 4)` in the
  # Haskell `.hi` comparator when GHC reports a 4-component snapshot version
  # (e.g. 9.12.4.20261102 on nixos-unstable); see
  # https://github.com/NixOS/nixpkgs/issues/592922. Included in diffoscope 340.
  ghcSnapshotPatchRev = "33826eb6d0cbc4bec0b6aa53b1d2f041fb54a51f";
  ghcSnapshotPatch = fetchpatch {
    name = "Handle-GHC-snapshot-versions-correctly.patch";
    url = "https://salsa.debian.org/reproducible-builds/diffoscope/-/commit/${ghcSnapshotPatchRev}.patch";
    hash = "sha256-lqZLUq/U6/5qaRT1tkHS21qZ5m2Zv7waDZY9fwsMV1A=";
  };

  hasGhcSnapshotFix =
    old:
    lib.versionAtLeast old.version "340"
    || lib.any (
      p: (p.name or "") == ghcSnapshotPatch.name || lib.hasInfix ghcSnapshotPatchRev (p.url or "")
    ) (old.patches or [ ]);
in
diffoscope.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ lib.optional (!hasGhcSnapshotFix old) ghcSnapshotPatch;
  passthru = builtins.removeAttrs (old.passthru or { }) [ "updateScript" ];
})
