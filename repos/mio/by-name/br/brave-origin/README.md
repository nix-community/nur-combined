## brave-origin

From-source Brave Origin browser (Linux + Darwin) using a vendored copy of
nixpkgs' Chromium packaging plus Brave overlays / FODs.

### Vendored Chromium

`chromium/` is copied from nixpkgs
[`pkgs/applications/networking/browsers/chromium`](https://github.com/NixOS/nixpkgs/tree/104240a772428cc2e20d8fd86c9ddbb886bbaff2/pkgs/applications/networking/browsers/chromium)
at commit **`104240a772428cc2e20d8fd86c9ddbb886bbaff2`**
(channel snapshot `nixpkgs-26.11pre1046984.104240a77242`, flake input
`https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz`).

Local Darwin patches live on top of that baseline (`chromium/common.nix`,
`mk-chromium.nix`). Re-vendor carefully and update this commit note when
refreshing.

### Layout

| File | Role |
|------|------|
| `browser.nix` | Brave Origin browser build (default package) |
| `mk-chromium.nix` | Wrapper around vendored `chromium/common.nix` |
| `chromium/` | Vendored nixpkgs Chromium packaging (Darwin-patched) |
| `src-package.nix` | Source-tree materialization only (`passthru.pinnedSrc`) |
| `source.nix` / `source-lock.json` | Version pins + npm/depot pins |
| `gclient-deps.json` | Brave overlay deps (gclient2nix) |
| `update.sh` | Maintainer lock refresh |

### Versions

Brave's Chromium tag in `brave-core` `package.json` must match nixpkgs
`chromium` in `info.json` (currently **151.0.7922.71** / rev
`ef35003457e93c278f911a334b06e4a5f8967e06`). Locked Brave is **1.93.131**.

Official Brave builds set a proprietary `brave_services_key`; this package
passes a non-empty placeholder so GN asserts succeed.

### Update

```bash
./by-name/br/brave-origin/update.sh <version-without-v>
```

Network is only expected in `update.sh`. Keep Chromium pins in
`source-lock.json` aligned with nixpkgs when bumping Brave.
