## brave-origin (source build)

Builds Brave Origin from pinned Chromium + brave-core sources using nixpkgs'
`mkChromiumDerivation`, offline FODs, and Brave overlays.

### Layout

| File | Role |
|------|------|
| `browser.nix` | Browser build (default package) |
| `src-package.nix` | Source-tree materialization only (`passthru.pinnedSrc`) |
| `source.nix` / `source-lock.json` | Version pins + npm/depot pins |
| `gclient-deps.json` | Brave overlay deps (gclient2nix) |
| `update.sh` | Maintainer lock refresh |

### Version alignment

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
