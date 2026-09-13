# Redrix coreboot firmware

Build the pinned `my` branch of `codgician/coreboot`:

```sh
nix build .#redrix-coreboot
```

The package uses upstream's `configs/adl/config.redrix.uefi`, its MrChromebox
EDK2 UEFI payload, and the pinned coreboot toolchain from Nixpkgs. The sole
firmware-content override is to embed `redrix-ec`'s `ec.RW.flat` instead of
the EC image in MrChromebox's blob repository. Firmware version strings also
identify the pinned NUR source revision.

`result/share/firmware/redrix-coreboot/` contains `coreboot.rom`,
`UEFIPAYLOAD.fd`, the resolved `coreboot.config`, the CBFS listing, exact source
pins, the embedded EC source revision, and SHA-256 checksums. The build checks
the 32 MiB ROM size, Redrix/UEFI configuration, payload presence, and embedded
EC bytes and hash. It does not establish that the firmware boots on hardware.

The ROM includes the descriptor, Intel ME, FSP, and microcode selected by
upstream. This is a generic build, not a backup of a particular machine's
flash or device-specific data. Building or installing the package does not
flash a device.

Update the source pins with:

```sh
nix develop -c .github/scripts/run_updater.sh redrix-coreboot
```

The shell updater uses `nix-update` to follow `codgician/coreboot:my`, including
all submodules through `fetchFromGitHub`. It then reads that source's selected
EDK2 release and updates the payload tag and hash using `nix-update`. If either
step fails, it restores the original pins. The build also checks that the pinned
EDK2 release matches the resolved coreboot configuration.

All build inputs are pinned; the firmware build does not fetch moving branches
or access the network. Compiler and other Nixpkgs dependencies advance through
`flake.lock`.

Update `redrix-ec` separately to advance the embedded EC firmware. Both packages
are discovered automatically by the NUR package set and update pipeline.
