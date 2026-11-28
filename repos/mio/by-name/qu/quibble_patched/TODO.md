# Quibble: pending work

`quibble`, `quibble_patched` and `quibble_win11_patched` build and pass their
OVMF boot checks, and `zfs-uefi` now reads encrypted datasets (raw keyfile and
passphrase, including datasets that inherit encryption from an ancestor).  What
remains is below.

The EFI-level leg is covered by
`checks.x86_64-linux.zfs-uefi-encrypted-efi-boot`: it creates an encrypted pool,
boots quibble + `zfs.efi`, types the passphrase, and checks that the dataset
mounts and that quibble reads `Windows/System32/ntoskrnl.exe` from it.

## 1. Real Windows installation test

- [ ] Source the ISO: Windows 10/11 Enterprise Evaluation from Microsoft's
      evaluation site (~5.5-6 GB).  Store it as a licence-gated fixed-output
      derivation (`meta.license = lib.licenses.unfree`, and a
      `config.microsoftVisualStudioLicenseAccepted`-style gate as
      `msvc-wine-toolchain` does), or accept a `windowsIso` path argument and
      fail with a clear message when it is null.
- [ ] Unattended install with `autounattend.xml`: install to a disk under
      `bootmgfw` first (setup cannot use quibble), then replace the boot path
      with quibble + `freeldr.ini` pointing at that Windows installation.
- [ ] Run under KVM (`/dev/kvm` is available), expect 30-60+ minutes of guest
      time; use `runNixOSTest`/`runCommand` with
      `requiredSystemFeatures = [ "kvm" ]` and a long `meta.timeout`, and keep
      it out of the default checks so `nix flake check` stays usable.
- [ ] Variant matrix: `quibble` (upstream stubs) and `quibble_patched` (real
      runtime) on the same disk image; then the ZFS leg with `zfs.efi` and a
      pool instead of an NTFS partition.
- Windows 11 additionally needs the `win11` branch / PR #144 loader changes
      (already packaged as `quibble_win11_patched`), so start with Windows 10
      21H2 for the boot matrix.

## 2. zfs-uefi encryption gaps

- [ ] AES-256-CCM datasets.  Only `aes-256-gcm` is accepted for the key object
      and for block encryption; CCM needs its CBC-MAC/CTR construction both in
      key unwrapping and in the block path.
- [ ] Encrypted ZIL (`DMU_OT_INTENT_LOG`) blocks are refused explicitly.  A
      pool exported cleanly has nothing to replay, but a dirty pool would need
      the intent log decrypted before its records can be read.
- [ ] The objset's *local* MAC is not checked.  The portable MAC (metadnode) is
      verified; the local MAC covers the user/group/project accounting dnodes,
      which do not affect file contents.
- [ ] Key format version 0 pools are refused (`ENOTSUP`).  Version 0 differs in
      the wrapped-key AAD (guid only) and in the block MAC field masking;
      supporting it read-only is a small, separate change.
- [ ] `keylocation=prompt` works in the EFI driver (console prompt), but a
      `keylocation` that names a file is not read by the driver: on a machine
      that boots from an encrypted dataset, the key has to be typed.  Reading
      the file from an unencrypted pool is possible but not implemented.

## 3. Reader limits that still bite

- [ ] Upstream's reader only knows FreeBSD's `features_for_read` feature set,
      and has no gzip, zstd or blake3.  A pool created by a newer OpenZFS with
      `compression=zstd`/`gzip` or a read-incompatible feature will not mount;
      adding zstd/gzip is a decoder task in `src/engine/`.
- [ ] The reader mounts `bootfs` (or the pool root) only; there is no
      `encryptionroot` selection beyond the walk to the key object, and no way
      to mount a differently named dataset from the loader.

## Test fixture notes

Useful when extending `checks.x86_64-linux.zfs-uefi-reader`:

- The pool must sit on a loop device; the reader rejects `file` vdevs.
- `bootfs` is what selects the dataset the reader mounts.
- A non-interactive VM cannot use `keylocation=prompt` for `zfs create` /
  `zfs load-key` (they read `/dev/tty`), so fixtures use `keyformat=raw` with
  `keylocation=file:///root/zfs.key`.  Creating a child of an encrypted dataset
  needs `zfs load-key tank/enc` first.
- The reader prints `dataset key loaded: aes-256-gcm`, `mount rc`, and
  `hello.txt: '<text>'`; assert on those rather than on filesystem state.
