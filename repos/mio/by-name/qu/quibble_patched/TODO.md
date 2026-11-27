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
* GCC 16 in this nixpkgs makes upstream's implicit function declarations hard
  errors, and `-w` cannot silence them; `zfs-uefi` relaxes
  `implicit-function-declaration`/`implicit-int`/`int-conversion` instead of
  patching the FreeBSD reader.

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

### QEMU boot harness findings 2026-11-27

The harness works; our images do not start under it.

* A 128 MiB GPT disk with one FAT32 ESP at sector 2048, populated with
  `mtools` (`/EFI/BOOT/BOOTX64.EFI` plus `drivers/`), boots a *control*
  loader: `systemd-bootx64.efi` placed as `BOOTX64.EFI` starts and prints to
  the console. So the partition table, FAT layout and OVMF setup are sound.
* Upstream's own release (`quibble-20230328.zip`, `amd64/quibble.efi`) boots in
  the same harness: it switches the GOP mode to 1280x800 and the captured
  framebuffer is ~5.5% non-black.
* Both `quibble` and `quibble_patched` fail to start: OVMF falls through to the
  "Please select boot device" menu at 2560x1600 with no quibble console output.
  The failure is therefore in our build, not in the harness or in the patched
  runtime.
* PE comparison against upstream's release: same `Characteristics` (0x2226,
  including `DLL`), same subsystem 10, both have `.edata`, `.idata` and
  `.reloc`. Ours is 1.84 MB with `SizeOfImage` 0x17a000; upstream is 2.38 MB
  with 0x100000. Zeroing the import data-directory entry and clearing the
  `DLL` characteristic changed nothing, and stripping is not the cause (the
  shipped image still has the export/import/reloc sections).
* Not yet explained; the next step is the exact `LoadImage` status (UEFI Shell
  `load` prints it) and a link-flag bisect:
  `-Wl,--disable-runtime-pseudo-reloc` is the prime suspect, then
  `-Wl,--dynamicbase`/`--nxcompat` defaults and `-lgcc` placement. Screendumps
  are captured with a QMP `screendump` after ~30 s, which is how the above was
  measured; no assertion can be written until the image starts.

## Tasks

### 1. Package `zfs-uefi` (upstream variant)

- [x] `by-name/zf/zfs-uefi/package.nix`: `fetchFromGitHub` at the pinned
      `rev`/`hash` above, `pkgsCross.mingw-msvcrt-x86_64`, `cmake`/`ninja`,
      gnu-efi include paths via `NIX_CFLAGS_COMPILE`, `hardeningDisable = [ "all" ]`.
- [x] Patch only its `mingw-amd64.cmake` (`nix.patch` beside `package.nix`):
      `-static` -> `-static -nostdlib -nodefaultlibs
      -Wl,--disable-runtime-pseudo-reloc`, `CMAKE_C_COMPILER_WORKS`, `-lgcc`.
      Keep the source tree otherwise untouched; it has no dummy block to remove.
- [x] `install -Dm644 zfs.efi $out/share/zfs-uefi/zfs.efi` plus LICENCE/README.
- [x] `passthru.updateScript` (nix-update-script with `--version=branch`,
      `0-unstable-<date>` versioning), then `git add` and `nix build .#zfs-uefi`.
- **Done 2026-11-27.** `nix build .#zfs-uefi` passes; output is
  `PE32+ ... EFI (boot service driver)`, zero `__imp_*` symbols.

### 2. Ship `zfs.efi` with `quibble_patched`

- [x] Add `zfs-uefi` as an argument of `quibble_patched/package.nix` and install
      its binary as `$out/share/quibble/drivers/zfs.efi` (quibble loads every
      driver in `drivers/` at startup).
- [x] Keep `quibble` (upstream variant) without the ZFS driver, so the two
      variants stay distinguishable.
- [x] Document the `freeldr.ini` side: `SystemPath=multi(0)disk(0)rdisk(0)partition(N)\Windows`
      (zfs-efi deliberately does not implement `GetArcName`), pool
      `compatibility=` limited to `features_for_read`, and `OpenZFS.sys` as a
      boot-start driver in the guest.
- **Done 2026-11-27.** Both variants build; `quibble_patched` ships
  `drivers/zfs.efi` (plus its LICENCE) next to btrfs/ntfs, `quibble` does not.

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

- [x] GPT disk with one FAT32 ESP (parted + `mtools` at sector 2048),
      `/EFI/BOOT/BOOTX64.EFI` plus `drivers/`, `OVMF_VARS.fd` copied writable,
      `qemu-system-x86_64 -machine q35 -m 2048 -nographic -no-reboot` with
      pflash CODE/VARS and the disk on IDE. Verified with a systemd-boot
      control and with upstream's release binary.
- [x] Assert that quibble itself ran, without trusting the graphics mode:
      `by-name/qu/quibble/vm-test.nix` requires `BdsDxe: starting Boot` in the
      serial log, no "Please select boot device" fallback, and a non-black QMP
      `screendump`; it then repeats the boot *without* `freeldr.ini` and
      requires the firmware fallback to appear, so the assertion is known to
      bite instead of passing on any firmware menu.
- [x] Wire both variants as explicit `checks.x86_64-linux` entries
      (`quibble-vm-boot`, `quibble-patched-vm-boot`), following the
      `lastbook-patched-setup` pattern.
- [x] Keep the check offline: QEMU (TCG, no KVM needed), OVMF, mtools,
      dosfstools, gptfdisk and python3 all come from the store.
- **Done 2026-11-27.** Both checks build and pass:
      `nix build .#checks.x86_64-linux.quibble-vm-boot` and
      `...#quibble-patched-vm-boot`. Measured on this machine: the good run
      keeps quibble's menu (1.70% non-black at 2560x1600) with
      `BdsDxe: starting Boot0002` and no fallback line; the no-`ini` control
      run shows `Please select boot device` (1.38%, the firmware menu).

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

- [x] Update scripts: `zfs-uefi` and `quibble` each carry their own
      (`nix-update --version=branch`, `0-unstable-<date>`, plus quibble's CMake
      version prefix), and `quibble_patched` now exposes
      `passthru.updateScript`, which runs both in order because the variant has
      no pins of its own - its loader follows `quibble` and its `zfs.efi`
      follows `zfs-uefi`. `check_updates.py` reports the two
      `fetchFromGitHub` pins; `quibble_patched` carries no `src`, so it is
      deliberately not listed there.
- [x] Documentation for both variants: `meta.longDescription` now states the
      install layout (`freeldr.ini` and `font.ttf` beside the loader,
      `drivers/` next to them) and, for `quibble_patched`, that it tracks the
      same upstream revision as `quibble` with only local runtime/ZFS patches.
- [x] Re-check that `nix build .#quibble` and `nix build .#quibble_patched`
      still pass after any `print.cpp`/toolchain churn upstream. Verified again
      2026-11-27 with a real run of the update scripts: `update-zfs-uefi` and
      `update-quibble` both fetched upstream and reported the pins already
      current (`0-unstable-2026-10-29`, `20230328-unstable-2024-06-23`), leaving
      the tree untouched; `update-quibble_patched` chained both the same way.
      `nix build` for all three packages and both VM checks still passes.

### 7. `quibble_win11` variant (openzfsonwindows `win11` branch)

- [x] `by-name/qu/quibble_win11/package.nix` pins the branch head
      (`c830ce7c5cea88c174f95a9d9758d68cbd570873`, 2026-11-04) with `fetchgit` +
      submodules. Our toolchain patch applies unchanged (the branch's
      `mingw-amd64.cmake` is identical to the pinned master's); the branch only
      adds `funcoverride.cpp/h` and changes `boot/mem/peload/quibble.h/win.h`.
- [x] The variant inherits `quibble`'s build but repeats `installPhase`: the
      inherited one interpolates the base package's source path for
      README/LICENCE/font.ttf, which would ship master's files with win11 code.
- [x] `checks.x86_64-linux.quibble-win11-vm-boot` boots it under OVMF and passes,
      so PR #144's loader changes work with this toolchain.
- [x] `passthru.updateScript` reads `refs/heads/win11` itself (nix-update has no
      `--rev`), then rewrites rev, the tree hash of that rev and the
      commit-date version from the GitHub API; two consecutive runs leave the
      file byte-identical at the current pin.
- Windows 11 itself still needs a real installation (task 5); this proves the
  loader builds and reaches its boot menu, nothing beyond that.

<!-- qemu-crash:start -->
### QEMU crash analysis (2026-11-27)

The images *do* start, and OVMF's exception handler catches them. `-serial file:` is
required to see firmware output at all (`-display none` alone sends `ConOut` to the
invisible graphics console).

```
!!!! X64 Exception Type - 06(#UD - Invalid Opcode)  CPU Apic ID - 00000000 !!!!
RIP  - 000000007DD4A00C   (second run: 000000007DD4900C)
```

Both RIPs are `load base + 0xC`, i.e. inside the DOS header, where mingw's stub has
`ff ff` — an invalid opcode. The file's own `AddressOfEntryPoint` is `0x14210`
(`SizeOfImage 0x179000`) and disassembly there is `efi_main`'s prologue, so the file
itself looks right. Either firmware really starts the image at `0xC`, or the RIP sits
elsewhere in a page-aligned allocation. QEMU's `-d in_asm` log contains no translated
block at either `0x7dd4*` / `0x7dd5*` page, but that log is cut off by the SIGTERM to
QEMU, so treat "entry = 0xC" as an inference, not a measurement. Instrumenting `efi_main` with direct
COM1 `outb` markers (bypassing the firmware console) produces **no marker at all**, so
its body never executes.

Control in the same harness: upstream's released `quibble.efi` boots to the quibble UI
(1280x800, 5.5% non-black) with no exception.

Ruled out as the cause (each variant still crashes the same way):

- stripping — a `dontStrip = true` build crashes identically;
- `-Wl,--disable-runtime-pseudo-reloc` — variant without the flag crashes;
- the freestanding CRT — a `-static` (upstream's own flags) variant crashes;
- `freeldr.ini` / `font.ttf` — upstream's own shipped files were used.

Next: load the image from OVMF's internal shell (`load fs0:\EFI\BOOT\BOOTX64.EFI`) for
the exact status, compare `SizeOfOptionalHeader`/`NumberOfRvaAndSizes`/data directories
against the release binary, and try `-Wl,--image-base,0` or an older binutils.

<!-- qemu-crash:end -->

<!-- pe-layout:start -->
### PE layout comparison (ours vs upstream release)

```
--- quibble.efi (/nix/store/fy1q6zif9yyvfmvl5c2cpfcxkmyjx1sg-quibble-x86_64-w64-mingw32-20230328-unstable-2024-06-23/share/quibble/quibble.efi)
  entry=0x14210 sizeOfHeaders=0x400 sizeOfImage=0x179000 nrva=16
  dirs: 0@0x169000+0xd957, 1@0x177000+0x18, 3@0x159000+0x6114, 5@0x178000+0xce4
  sections: .text@0x1000+0x10ee00, .data@0x110000+0x30800, .rdata@0x141000+0x200, .rodata@0x142000+0x16200, .pdata@0x159000+0x6200, .xdata@0x160000+0x7400, .bss@0x168000+0x680, .edata@0x169000+0xda00, .idata@0x177000+0x200, .reloc@0x178000+0xe00
  relocs: 1566, rva range 0x110000..0x140280, outside headers/image: 0 []
--- quibble.efi (/tmp/qv/upstream/amd64/quibble.efi)
  entry=0xf0c7 sizeOfHeaders=0x400 sizeOfImage=0x100000 nrva=16
  dirs: 0@0xc3000+0x3ad0c, 1@0xfe000+0x18, 3@0xb2000+0x79f8, 5@0xff000+0x5e8
  sections: .text@0x1000+0xa3e00, .data@0xa5000+0x200, .rdata@0xa6000+0xbc00, .pdata@0xb2000+0x7a00, .xdata@0xba000+0x7c00, .bss@0xc2000+0x420, .edata@0xc3000+0x3ae00, .idata@0xfe000+0x200, .reloc@0xff000+0x600
  relocs: 724, rva range 0xa7160..0xb1500, outside headers/image: 0 []
```

<!-- pe-layout:end -->

<!-- qemu-status:start -->
### Status correction: the #UD dumps came from broken instrumentation builds

Booting the *unmodified* build (entry `0x14210`) on a fresh GPT/ESP image built with
`parted` + `mkfs.vfat -F 32 -s 1` + `mcopy` produces **no exception at all**: firmware
logs `BdsDxe: loading Boot0002 "UEFI QEMU HARDDISK"` and then falls back to
`BootManagerMenuApp`, i.e. the image is loaded/rejected without ever crashing.

Control on the *same* disk layout, only `BOOTX64.EFI` swapped for upstream's release
binary: boots the quibble UI (1280x800, 5.49% non-black). So the ESP layout, the
512-byte clusters, and the shipped `freeldr.ini`/`font.ttf` are all fine.

The two images that produced the `#UD` dumps have `AddressOfEntryPoint = 0` — confirmed
both in the file and in the loaded copy in guest RAM, where the loader had already
rewritten `ImageBase` to `0x7dd49000`. They came from my earlier ad-hoc instrumentation
builds, so the "crash at image base + 0xC" is an artifact of those images, not evidence
about quibble. Header comparison with the release binary shows nothing invalid either:

```
ours:     entry=0x14210 nsec=10 sizeimage=0x179000 sizeofheaders=0x400 FileAlign=0x200 SectAlign=0x1000
upstream: entry=0x0f0c7 nsec=9  sizeimage=0x100000 sizeofheaders=0x400 FileAlign=0x200 SectAlign=0x1000
```

Next: rebuild the COM1-marker instrumentation through `overrideAttrs` (entry stays
`0x14210`), boot it, and read the `qstat` markers to see how far `efi_main` gets.

<!-- qemu-status:end -->

<!-- markers:start -->
### Root cause of the bogus #UD: a broken `extern "C"` in my instrumentation

In `/tmp` scratch patches I inserted the `qport`/`qstat` helpers between a bare
`extern "C"` line and `efi_main`. A linkage specification without a block applies only to
the *next* declaration, so `efi_main` silently became C++-mangled, the linker could not
find it, and it defaulted `AddressOfEntryPoint` to **0**. That is the entire "crash at
image base + 0xC": the firmware was executing the DOS header.

With `extern "C"` restored on `efi_main` (entry `0x142c0`) the same build runs, and the
COM1 markers show `efi_main` succeeding all the way through the stack switch:

```
BdsDxe: loading Boot0002
BdsDxe: starting Boot0002
S=00000000   (entered efi_main)
c=00000000   (ConIn->Reset)
f=00000000   (load_font)
g=00000000   (set_graphics_mode)
i=00000000   (info_register)
r=00000000   (reg_register)
p=00000000   (pe_register)
d=00000000   (load_efi_drivers)
b=00000000   (look_for_block_devices)
k=00000000   (change_stack)
R=00000000   (continuation after the stack switch)
```

After that point quibble returns and firmware shows the boot menu; nothing is drawn and
no exception is raised. So the remaining question is narrow: what runs after
`change_stack` and why it bails out.

<!-- markers:end -->

<!-- menu-marker:start -->
### Where it actually stops: `show_menu` returns EFI_NOT_FOUND

Instrumenting the branches of `stack_changed` (which runs on the switched stack) gives:

```
b=00000000   look_for_block_devices
m=00000000   entered stack_changed
n=0000000e   show_menu -> EFI_NOT_FOUND (14)
e=0000000e   took the EFI_ERROR branch, print_error("show_menu"), return
k=00000000   change_stack returned, efi_main unwinds
R=00000000   efi_main returns EFI_SUCCESS to firmware
```

So everything quibble does to set itself up succeeds; only the boot-menu path cannot
find something. Upstream's release binary on this exact ESP finds it, so the difference
is in our build, not the disk.

<!-- menu-marker:end -->

<!-- resolved:start -->
### Resolved: the packaged binaries boot and render the menu

The build was never broken. Two things had to be right in the ESP, and one of them was
missing from the test image:

1. `freeldr.ini` and `font.ttf` must sit **in the same directory as the loader**, not at
   the ESP root: `load_ini_file` opens `freeldr.ini` relative to
   `open_parent_dir(loaded_image->FilePath)`. Without it, `show_menu` returns
   `EFI_NOT_FOUND` and `efi_main` unwinds straight back to firmware - the symptom that
   looked like "quibble doesn't boot".
2. A boot option that resolves on the test machine. The release config points at
   `multi(0)disk(0)rdisk(0)partition(3)\Windows`, so on a one-partition test disk
   `parse_arc_name` returns `EFI_INVALID_PARAMETER` and quibble stops after the menu.

Verified layout (both `quibble` and `quibble_patched`):

```
gpt disk 128 MiB, ESP fat32 1..65 MiB (parted + mkfs.vfat -F 32 -s 1)
  \EFI\BOOT\BOOTX64.EFI   <- our quibble.efi
  \EFI\BOOT\freeldr.ini   <- config, next to the loader
  \EFI\BOOT\font.ttf
  \drivers\btrfs.efi, \drivers\ntfs.efi
boot: qemu-system-x86_64 -machine q35 -m 2048 -smp 2 -display none
      -drive if=pflash,...OVMF_CODE.fd -drive if=pflash,...OVMF_VARS.fd
      -drive if=ide,...disk.img        (plus -serial file: to see firmware output)
```

Result: `BdsDxe: starting Boot0002`, no exception, and the quibble menu is on screen
(1.79% non-black at 2560x1600 sampled at 6 s, against a black screen without the config).
Booting an OS from there needs a real Windows install, which is task 5.

Packaging gap found here: our install ships `quibble.efi`, `drivers/`, `LICENCE` and
`README.md`, but not the `font.ttf` in upstream's source tree and release archive.
`freeldr.ini` is not in the source at all, so it cannot be shipped - the docs must say to
put it beside the loader.

<!-- resolved:end -->
