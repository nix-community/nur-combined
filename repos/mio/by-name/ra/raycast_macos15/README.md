# raycast_macos15

Vendored copy of nixpkgs `raycast` pinned to the last **Raycast v1** release. Upstream nixpkgs now ships **Raycast 2.x**, which requires **macOS 26 Tahoe** and does not run on **macOS 15.x (Sequoia)**.

## Upstream (nixpkgs)

Copied on **2026-08-29** from nixpkgs commit immediately before the `1.104.24 -> 2.0.5.0` bump:

| Field | Value |
| --- | --- |
| nixpkgs rev | [`b4955aefefab0664a8747399c3c005383ce04952`](https://github.com/NixOS/nixpkgs/commit/b4955aefefab0664a8747399c3c005383ce04952) |
| Upstream path | `pkgs/by-name/ra/raycast/package.nix` |
| Package version | `1.104.24` |
| Superseded by | [`9ef4b20ce659`](https://github.com/NixOS/nixpkgs/commit/9ef4b20ce659) (`raycast: 1.104.24 -> 2.0.5.0`) |

`package.nix` started from that commit, then the local changes below were applied.

To refresh: copy `package.nix` from a newer nixpkgs commit only if Raycast regains macOS 15 support, update this table, then re-apply the local changes.

## Local changes

- `pname` is `raycast_macos15` so it does not collide with upstream nixpkgs `raycast` (2.x).
- `meta.description` notes macOS 15 compatibility.
- `meta.mainProgram` and `$out/bin/raycast` symlink (from newer nixpkgs packaging).
- Upstream `passthru.updateScript` removed: it tracks latest Raycast, which is now v2 and incompatible.
