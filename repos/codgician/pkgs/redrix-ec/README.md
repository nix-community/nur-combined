# Redrix EC firmware

Build the pinned `my` branch of `codgician/redrix-ec`:

```sh
nix build .#redrix-ec
```

`result/share/firmware/redrix-ec/` contains the full 512 KiB `ec.bin`, the
individual RO/RW flat images and debug ELFs, `ec.RW.bin`, the version header,
source revision, package and firmware versions, and SHA-256 checksums.

The package version is `<major>.<minor>.<patch+distance>-g<commit8>`, following
upstream's EC version calculation from the nearest reachable `v*` release tag.
The distance includes downstream patches. Both firmware regions embed exactly
`redrix_${version}`, retaining upstream's board-name prefix. The build rejects
identities longer than 31 bytes rather than silently truncating them. The
Gitless version generator's placeholder is replaced with the package version;
the rest of upstream's header generation is retained. For this standalone build,
the ChromeOS FWID field also uses `redrix_${version}` instead of
`CROS_FWID_MISSING`, so `ectool version` reports the same identity for both
fields. This identifies the Nix build, rather than a ChromeOS release.

The build uses ARM GNU Toolchain 13.3.Rel1 and host GCC 13. The package runs
the native lid-switch and MKBP tests and checks both firmware regions' sizes,
placement, and identity. Hardware behavior still requires testing on Redrix.

Update the source pin to the latest `my` commit using the repository's updater:

```sh
nix develop -c .github/scripts/run_updater.sh redrix-ec
```

The updater resolves the version from the exact new source pin and reachable
tags in the Chromium upstream repository, then writes that metadata to the
package expression. If source or version resolution fails, it restores the
original expression. Git history is fetched only at update time; builds remain
offline. The independent `cryptoc` source stays explicitly pinned, while
compiler and other Nixpkgs dependencies advance through `flake.lock`.

`redrix-coreboot` embeds this package's `ec.RW.flat`, so an EC package update
also rebuilds coreboot. These packages produce firmware artifacts; building or
installing them does not flash a device.
