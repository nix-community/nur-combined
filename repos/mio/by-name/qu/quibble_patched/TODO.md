# Quibble: ZFS, encryption and QEMU test work

Pending work after `quibble` (upstream-faithful) and `quibble_patched` (real
setjmp/longjmp runtime) were packaged. Facts below were checked on 2026-11-27;
re-check the pins before relying on them.

## Facts established

### openzfsonwindows/quibble branches

`git ls-remote`/API on `https://github.com/openzfsonwindows/quibble`:

| Branch | Head | Note |
| --- | --- | --- |
| `master` | `7402412537678e46f40613a7a4a73644a2d0f68c` | same revision our `quibble` package pins (upstream maharmstone/quibble) |
| `win11` | `c830ce7c5cea88c174f95a9d9758d68cbd570873` | Windows 11 loader work, still open as PR #144 against maharmstone/quibble |
| `zfs-driver` | `c0f7502e7842eb2c2fe6a19abbfd1b0551c977cd` | driver-loading changes used by the ZFS boot setup |
| `hypercall-page` | `a82384ecab12cfa095ad3a2c2afda4a66cf2bca2` | unrelated (hypercall page) |

`zfs-efi`'s README says Windows 11 needs the loader changes of Quibble PR #144,
i.e. the `win11` branch content. Any Windows 11 boot test needs that branch or
the merged PR, not `master`.

### zfs-efi (the UEFI ZFS driver Quibble loads)

* Repo: `https://github.com/openzfsonwindows/zfs-efi`, master
  `8cdbd7b2c299159a9a03698e90c79b46c5ed267b` (2026-11-27).
* Tarball SRI: `sha256-cIVAPcTldTdlbpDfdC496rk72aBbYQno+uxHyUraov8=`
  (143628 bytes, `archive/<sha>.tar.gz`).
* No GitHub releases (`/releases` is `[]`), so it must be built from source.
* CMake: `project(zfs-uefi C)`, target `zfs` with `SUFFIX ".efi"`, C11,
  gnu-efi headers from `/usr/include/efi`, `-nostartfiles -shared`,
  `--subsystem,11`, entry `efi_main`. Own toolchain `mingw-amd64.cmake` is the
  same as quibble's and sets only `-static`.
* Sources split in two worlds: EFI side (`src/zfs.c`, `src/misc.c`,
  `src/runtime.c`) and FreeBSD's boot-time reader (`src/zfsengine.c`,
  `src/engine/*`) built with `src/compat/prefix.h` and `-w`.
* Reader limits (from its README): no encryption, no gzip, no zstd, no blake3,
  only the FreeBSD `features_for_read` pool features; `bootfs` or pool root is
  the file-system root; `GetWindowsDriverName` returns `OpenZFS`, so
  `OpenZFS.sys` must be a boot-start driver in the SYSTEM hive.
* Same environment shape as quibble: `-static` on a freestanding image means
  the toolchain file needs the quibble treatment (drop the CRT: `-nostdlib
  -nodefaultlibs`, `CMAKE_C_COMPILER_WORKS`, `-lgcc`) before it links in
  nixpkgs' mingw. Expect the same `atexit`/`_setjmp` class of failures.

### Encryption

`zfs-efi` README, verbatim: "The reader doesn't know about encryption, so the
pool or dataset can't be encrypted." Adding it is not a quibble change: it
means teaching the boot-time reader to unwrap dataset keys (AES-CCM/GCM key
wrapping, PBKDF2 for passphrases, `keyformat`/`keylocation`, and the
`com.datto:encryption`/`encryptionroot` properties). Encryption in OpenZFS on
Windows is likewise only in the kernel driver. Treat it as its own feature with
an upstream patch or a fork, not as a packaging flag.

### QEMU / OVMF

* `/dev/kvm` is present on this machine (`crw-rw-rw-`), so hardware
  acceleration is available for local runs.
* OVMF: `/nix/store/3z154ki9ifcfsn4q0663akwysl1gy28y-OVMF-202608-fd`
  (`FV/OVMF_CODE.fd`, `FV/OVMF_VARS.fd`). Copy VARS with
  `cp --no-preserve=mode` and `chmod u+w`, or QEMU cannot open it for writing.
* A bare FAT image (`truncate` + `mkfs.vfat` + `mcopy` of
  `/EFI/BOOT/BOOTX64.EFI`) is *not* enough: OVMF lists the disk but falls back
  to `BootManagerMenuApp` ("Please select boot device"), i.e. it does not find
  the loader. The image needs a partition table with a proper ESP partition
  (GPT, type `EF00`, FAT32), and the loader inside that partition.
* With `-nographic`, OVMF's console is mirrored to serial, so quibble's text
  output can be asserted on from the captured log; `-no-reboot` plus `timeout`
  keeps a run bounded.

## Tasks

### 1. Package `zfs-uefi` (upstream variant)

- [ ] `by-name/zf/zfs-uefi/package.nix`: `fetchFromGitHub` at the pinned
      `rev`/`hash` above, `pkgsCross.mingw-msvcrt-x86_64`, `cmake`/`ninja`,
      gnu-efi include paths via `NIX_CFLAGS_COMPILE`, `hardeningDisable = [ "all" ]`.
- [ ] Patch only its `mingw-amd64.cmake` (`nix.patch` beside `package.nix`):
      `-static` -> `-static -nostdlib -nodefaultlibs
      -Wl,--disable-runtime-pseudo-reloc`, `CMAKE_C_COMPILER_WORKS`, `-lgcc`.
      Keep the source tree otherwise untouched; it has no dummy block to remove.
- [ ] `install -Dm644 zfs.efi $out/share/zfs-uefi/zfs.efi` plus LICENCE/README.
- [ ] `passthru.updateScript` (nix-update-script with `--version=branch`,
      `0-unstable-<date>` versioning), then `git add` and `nix build .#zfs-uefi`.
- Done when the derivation builds, `file` says `PE32+ ... EFI`, and no
  `__imp_*` symbols survive under `-nostdlib`.

### 2. Ship `zfs.efi` with `quibble_patched`

- [ ] Add `zfs-uefi` as an argument of `quibble_patched/package.nix` and install
      its binary as `$out/share/quibble/drivers/zfs.efi` (quibble loads every
      driver in `drivers/` at startup).
- [ ] Keep `quibble` (upstream variant) without the ZFS driver, so the two
      variants stay distinguishable.
- [ ] Document the `freeldr.ini` side: `SystemPath=multi(0)disk(0)rdisk(0)partition(N)\Windows`
      (zfs-efi deliberately does not implement `GetArcName`), pool
      `compatibility=` limited to `features_for_read`, and `OpenZFS.sys` as a
      boot-start driver in the guest.
- Done when both variants build and the patched one contains all three drivers.

### 3. ZFS encryption in the patched variant

- [ ] Decide the shape first: patching FreeBSD's reader inside `zfs-efi`
      (upstreamable) vs. a `zfs-uefi_patched` carrying that patch. Do not fork
      silently.
- [ ] Scope the minimum: AES-256-GCM/CCM key unwrapping, PBKDF2 passphrase
      derivation, `encryptionroot` walk, `keylocation` prompt path in quibble.
- [ ] Gate on a pool made by OpenZFS on Windows with `encryption=on` and an
      unencrypted `bootfs` being the fallback case.
- Blocked until tasks 1-2 land; the reader currently cannot read wrapped keys at
  all, so this is a feature implementation, not a build flag.

### 4. QEMU boot checks for both variants

- [ ] `by-name/qu/quibble/vm-test.nix` (parameterised by the package under
      test): build a GPT disk with one FAT32 ESP (`sgdisk`/`parted` + `mtools`
      at the right offset), populate `/EFI/BOOT/BOOTX64.EFI` plus `drivers/`,
      copy `OVMF_VARS.fd` writable, run
      `qemu-system-x86_64 -machine q35 -m 2048 -nographic -no-reboot` with
      pflash CODE/VARS and the disk attached by IDE.
- [ ] Assert on the serial log that quibble itself ran (its own output after
      `BdsDxe:`), not merely that OVMF booted; fail on the boot-device menu
      (`Please select boot device`) which is the current symptom of a missing
      ESP.
- [ ] Wire both as checks. The flake auto-discovers `packages.<name>.tests.<n>`
      (`flake.nix` around the `packageTests` block), so add
      `tests.vm-boot` to `quibble` and `quibble_patched` (or explicit
      `checks.<system>` entries alongside `lastbook-patched-setup`).
- [ ] Keep the check offline: everything it needs comes from the store.
- Done when `nix build .#checks.x86_64-linux.quibble-vm-boot` and the
  `quibble_patched` equivalent pass, and both fail on a deliberately wrong ESP
  layout (verify the assertion actually bites).

### 5. Real Windows installation test

- [ ] Source the ISO: Windows 10/11 Enterprise Evaluation from Microsoft's
      evaluation site (~5.5-6 GB). Store it as a licence-gated fixed-output
      derivation (`meta.license = lib.licenses.unfree`, and a
      `config.microsoftVisualStudioLicenseAccepted`-style gate as
      `msvc-wine-toolchain` does), or accept a `windowsIso` path argument and
      fail with a clear message when it is null.
- [ ] Unattended install with `autounattend.xml`: install to a disk under
      `bootmgfw` first (setup cannot use quibble), then replace the boot path
      with quibble + `freeldr.ini` pointing at that Windows installation.
- [ ] Run under KVM (`/dev/kvm` is available), expect 30-60+ minutes of guest
      time; use `runNixOSTest`/`runCommand` with `requiredSystemFeatures =
      [ "kvm" ]` and a long `meta.timeout`, and keep it out of the default
      checks so `nix flake check` stays usable.
- [ ] Variant matrix: `quibble` (upstream stubs) and `quibble_patched` (real
      runtime) on the same disk image; then the ZFS leg with `zfs.efi` and a
      pool instead of an NTFS partition.
- Blocked: not attempted yet. Needs the ISO download, a working GPT ESP harness
  from task 4, and a decision on where the multi-GB ISO lives (the repo must
  not carry it).
- Windows 11 additionally needs the `win11` branch / PR #144 loader changes, so
  start with Windows 10 21H2 for the boot matrix.

### 6. Housekeeping once the above lands

- [ ] Update scripts for `zfs-uefi` (and the pin of `zfs-efi` inside
      `quibble_patched`) so a bump moves revision, hash and README reference
      together; `./check_updates.py` must see them.
- [ ] README/description updates for both variants, and a note in
      `quibble_patched` about which upstream branch its patches came from.
- [ ] Re-check that `nix build .#quibble` and `nix build .#quibble_patched`
      still pass after any `print.cpp`/toolchain churn upstream.
