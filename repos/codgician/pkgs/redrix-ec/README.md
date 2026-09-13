# Redrix EC firmware

Build the pinned `my` branch of `codgician/redrix-ec`:

```sh
nix build .#redrix-ec
```

`result/share/firmware/redrix-ec/` contains the full 512 KiB `ec.bin`, the
individual RO/RW flat images and debug ELFs, `ec.RW.bin`, the version header,
source revision, and SHA-256 checksums. Each image identifies its source as
`redrix_v2.1.9999-<commit>`, using upstream's `VCSID` packaging interface.

The build uses ARM GNU Toolchain 13.3.Rel1 and host GCC 13. The package runs
the native lid-switch and MKBP tests and checks both firmware regions' sizes,
placement, and identity. Hardware behavior still requires testing on Redrix.

Update the source pin to the latest `my` commit using the repository's updater:

```sh
nix develop -c .github/scripts/run_updater.sh redrix-ec
```

`redrix-coreboot` embeds this package's `ec.RW.flat`, so an EC package update
also rebuilds coreboot. These packages produce firmware artifacts; building or
installing them does not flash a device.
