# Radxa Orion O6 UEFI firmware

Build the pinned `sky1` branches of `codgician/edk2` and
`codgician/edk2-platforms` for the Orion O6:

```sh
nix build .#orion-o6-edk2
```

The firmware adds a firmware TPM, measured boot and the related hardening to
Radxa's CIX Sky1 release. Radxa's `edk2-cix` packaging repository supplies only
the board build glue; CIX's prebuilt components come from the pinned
`radxa/edk2-non-osi`. Only `aarch64-linux` builds are supported: the vendor
packaging tools run natively there.

`result/share/firmware/orion-o6-edk2/` contains `cix_flash_ota.bin` (the
bootloader3 update image), `cix_flash_all.bin` (the full 8 MiB flash image),
the UEFI FD `SKY1_BL33_UEFI.fd`, its main volume `FVMAIN.Fv`, EDK2's
`BuildOptions`, the exact source pins, SHA-256 checksums and `pcr0`.

`pcr0` gives the SHA-256 and SHA-384 PCR0 values of a healthy boot of this
image. The firmware extends PCR0 with `FVMAIN.Fv` (the code that runs after
PrePi) before the ReadyToBoot separator, so PCR0 changes whenever that code
does. This is a measurement by the firmware itself: it detects a different
firmware build, not a malicious image that skips or forges the measurement.

The same pins always produce the same `FVMAIN.Fv`, FD and `pcr0`. The build
date and PrePi's `__DATE__` come from the newest pinned commit, and EDK2's
per-build random stack-cookie table is derived from the pins instead. The
flash images additionally contain certificates created by CIX's signing tool
at build time, so their bytes outside the embedded FD differ between builds.

The build checks the image sizes, that both flash images embed the FD
unchanged, and that the PCR0 measurement driver is present. The firmware's
host unit tests and fuzz smoke runs build as a separate check:

```sh
nix build .#checks.aarch64-linux.orion-o6-edk2
```

Neither establishes that the firmware boots on hardware. Building or installing
the package does not flash a device.

Update both firmware pins to the tips of their `sky1` branches with:

```sh
nix develop -c .github/scripts/run_updater.sh orion-o6-edk2
```

The updater also moves the build date and package version to the newest pinned
commit, and restores the original pins if any step fails.
