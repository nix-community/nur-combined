# eihort: offline extraction, LUKS reinstall, and restore plan

This is the fallback extraction/reinstall plan, not authorization to format disks or a record of completed data recovery. The rescue image was built/mounted remotely; a manual BMC reset was performed, then the operator disabled Secure Boot and booted the livecd. After successful SSH/storage checks, the operator chose to resume the original migration offline instead. No filesystem repair, reinstall, or source formatting has been performed.

## Recommendation

Boot an independent rescue ISO; assemble and read the old multi-device Btrfs; export persistent state to a new, separate encrypted dataset on `pool0`; verify the export and application recovery; then initialize a fresh LUKS/Btrfs filesystem on the NVMe data partition, reinstall the pinned NixOS configuration, and restore state before starting applications.

Do not resume online device removal merely to enable reinstall. Once the necessary data has been exported and verified independently, the old filesystem does not need to complete evacuation before its NVMe member is reused.

This is the lowest additional hardware/storage-cost route because `pool0` has available space. It still requires the old filesystem to be readable. The source staging ZVOL and the new backup share a physical pool, so this arrangement protects against NVMe reinstallation mistakes, not loss of the whole ZFS pool.

## Known state and device identities

- Btrfs UUID: `736e050f-7171-489c-9567-e5385e9c2e04`.
- Original member: `/dev/disk/by-id/nvme-eui.00000000000000008ce38e10014c244a-part3`.
- Staging member: `/dev/mapper/eihort-btrfs-stage`, backed by `/dev/zvol/pool0/eihort-luks-stage`.
- Staging LUKS UUID: `5488d99b-a4f2-4cf9-9ec0-e0938eb0bade`.
- Staging key/header are on hastur under `/home/riro/.local/state/eihort-luks/2026-11-18/`, outside the public repository.
- Last verified running state, 2026-11-18 19:26 +08: approximately 175 GiB allocated on the raw member and 207 GiB on staging. Removal completion is unverified; both members must be retained and made available.
- IPMI SEL subsequently showed two watchdog hard resets. The root cause of the preceding stall is unconfirmed.
- Original NVMe was not reformatted. The online evacuation service does not contain any formatting step.
- Hastur has only approximately 25 GiB free and is unsuitable as the destination for a complete persistent-state export.

## What must be preserved

| Source | Treatment |
| --- | --- |
| Old `var` subvolume | Mandatory. Preserve all application state, databases, WAL, SQLite companion files, Incus state/disks, service identities and persistent user/group databases. |
| Old `persist` subvolume | Mandatory unless the owner explicitly accepts losing its contents. It contains preserved home directories, SSH/GPG material, configuration and other user data. |
| `/var/lib/ssh/ssh_host_ed25519_key` | Critical identity. `mod/age.nix` uses this host identity with vaultix. Preserve the private key without displaying it. |
| `/var/lib/nixos` and `/var/lib/userborn` | Preserve numeric identity/password/sub-ID state for the same `elen` installation. Do not apply the unrelated UID-conflict guide's destructive cleanup by default. |
| Old `nix` subvolume | Prefer exporting the complete subvolume when measured capacity permits, preserving store, database and profiles together. Rebuilding is possible but adds dependency/version/local-input uncertainty. Do not restore an old Nix database into a fresh store without its registered contents. |
| Existing `pool0` application datasets | Leave in place. Preserve names, mountpoints, pool GUID and properties. They are not included merely by exporting the Btrfs `var` directory. |
| ESP, GPT, config and lockfile | Save small offhost copies/manifests before reinstall. Record the actual live partition layout. |

The existing rustic jobs explicitly back up PostgreSQL `all.sql`, not the whole persistent filesystem. `mod/postgresql-backup.nix` excludes database `relation`; that SQL dump is a fallback, not proof of complete database recovery.

`mod/postgresql.nix` uses PostgreSQL 17 with pgvector and VectorChord, and permits `/pool0/relation`. Inventory `pg_tblspc` and external WAL/tablespace symlinks before recovery. Keep the original PostgreSQL major and extension versions for physical recovery.

The declared Incus default storage driver is `dir`, with source `/var/lib/incus/storage-pools/default`; this makes metadata-preserving file export a reasonable primary route. Verify the actual on-disk pools and nested subvolumes rather than assuming preseed describes all live storage.

## Phase 1: independent rescue boot

Use a minimal NixOS ISO with compatible ZFS, Btrfs and cryptsetup, plus rsync, SSH, partition utilities and ipmitool. The available pinned nixpkgs source is `/nix/store/44zyg8i46md22kjs7hr3bdvia86rpd8p-source`, providing Linux 6.18.54, btrfs-progs 7.1, cryptsetup 2.8.7 and ZFS 2.4.4. The existing `mod/hosts/rescue.nix` has now been changed from the no-ZFS/testing-kernel variant to the compatible minimal installer, with explicit recovery tools and watchdog settings.

1. Make the ISO and its checksum available through IPMI virtual media.
2. Arrange Secure Boot compatibility. An ordinary installer ISO is not signed by enabling Lanzaboote elsewhere. If temporarily disabling Secure Boot is necessary, retain enrolled firmware keys; do not clear them.
3. Boot to a console/SSH-capable rescue system independent of the installed `/nix`.
4. Disable the BMC hardware watchdog and the rescue OS runtime watchdog, then read back the actual watchdog state. Merely avoiding the kernel watchdog module does not prove an already armed BMC timer is disabled.
5. Keep old swap inactive. Confirm device identities, pool GUID, capacity and hardware error counters. Prioritize extraction rather than running scrub, memory stress tests or repair first.

The ISO has been attached remotely and booted by the operator. SSH, hardware watchdog disarm, and access to both old Btrfs members have now been verified. The active strategy is offline continuation of device removal; the remaining reinstall steps below are a fallback.

### Prepared and mounted rescue media

- Built from `nixosConfigurations.rescue.config.system.build.isoImage`; build exited successfully.
- Raw ISO: `/var/tmp/eihort-rescue-media/livecd.iso` on hastur; 2,197,815,296 bytes (about 2.05 GiB), validated as bootable ISO9660/El Torito media.
- SHA-256: `00ab747663399c1ab23ef0d8a8d819a9510d119ccf99bcd25d455e456c055f0d`.
- BMC share host: `192.168.0.10`; image path: `\IPMI_ISO\livecd.iso`; guest read-only access.
- Temporary share service: `eihort-rescue-smb.service`, bound to `192.168.0.10:445`, restricted to the BMC. Configuration and cleanup helpers are under `/var/tmp/eihort-rescue-smb/`.
- BMC Device 1 reports `There is an iso file mounted.`; an established SMB connection from `192.168.0.9` was independently observed.
- Keep hastur and this service online until rescue media is no longer in use. The built compressed artifact is also pinned at `/home/riro/.local/state/eihort-luks/rescue-iso`.
- Root SSH authorized keys are retained from the existing rescue configuration. The image disables systemd watchdogs, blacklists `ipmi_watchdog`, and includes a conditional BMC-watchdog-off service; its actual hardware effect must be read back after boot.

## Phase 2: assemble and inspect the old filesystem

1. Import `pool0` with application datasets unmounted (`-N`), initially read-only, without updating its cache file or upgrading pool features. An import ownership override requires establishing that no other host is using the pool.
2. Wait for the staging ZVOL, supply the offhost staging key through the rescue connection/RAM, and open its LUKS mapper read-only.
3. Discover all existing Btrfs members. If removal completed just before the crash, the raw partition may no longer carry a valid member signature; determine actual membership rather than treating the last offhost status as current truth.
4. Attempt a read-only, no-log-replay mount of the top level (`ro,rescue=nologreplay,subvolid=5`) using the staging member. Inventory `var`, `persist`, `nix`, nested subvolumes, database paths and errors. Do not mount degraded as the default recovery route.
5. Do not start the old applications or resume removal.

Read-only ZFS import does not replay the ZIL. Btrfs `nologreplay` also intentionally avoids replaying its log tree. This first inspection is a conservative view, not proof that the newest fsynced files have been recovered; a failed mount against that older ZVOL view does not alone prove corruption. For the actual export, normally import ZFS writable with `-N` and allow its ordinary ZVOL log recovery, then open the source mapper and mount Btrfs read-only. Fully unmount Btrfs and close staging before exporting/reimporting the pool; never change the underlying ZVOL view beneath a mounted Btrfs. Import requiring rewind, discarded intent logs or other recovery flags is a stop-and-reassess condition. Preserve a snapshot/clone-based recovery option before any later Btrfs log replay or repair.

If normal read-only mounting fails, stop the reinstall path and assess non-destructive extraction, such as `btrfs restore` to a separate destination. Keep an explicit list of unreadable/missing files. Do not run `btrfs check --repair`, reformat, or assume that a partial `/var` export is sufficient.

## Phase 3: export to a separate encrypted destination

After the initial inspection, verify actual free space and file sizes. Create a **new** encrypted ZFS dataset, for example `pool0/recovery-eihort-20261118`, with a key kept offhost and temporary key material only in rescue RAM. Use `canmount=noauto`, a dedicated mountpoint, compression, normal synchronous-write semantics, and **`acltype=posix` plus `xattr=sa`** so ACL/xattr export works. Linux ZFS does not enable POSIX ACL storage by default.

Creating this destination requires a writable pool import. Export/reimport the pool in a controlled fashion with application datasets unmounted, account for ZFS log replay, reopen the source LUKS mapping read-only, and remount the old Btrfs read-only. Do not disable ZFS sync or upgrade pool features.

This destination is separate from `pool0/eihort-luks-stage`. Never create a backup directory inside the old Btrfs and mistake it for an independent export.

Export in priority order:

1. Critical service identities, PostgreSQL dump, persistent user/group databases and configuration manifests.
2. Full `var`, including application data and database recovery files.
3. Full `persist`, including preserved homes.
4. Prefer full `nix` when measured capacity allows; otherwise retain a usable current system closure and all source/lock/local-input material required to reconstruct the installation before erasing anything.

Use metadata-preserving file copying, e.g. `rsync -aHAXS --numeric-ids`, with explicit source/destination paths. Exclude only inventoried regenerable material; old top-level Snapy `.snapshots` trees can be omitted if historical retention is unnecessary. Preserve permissions, owners, ACLs, xattrs, hardlinks, symlinks and sparse files.

Do not blindly add `-x`: nested Btrfs subvolumes can have different device IDs and be skipped. Conversely, do not traverse live application datasets, `/proc` or other unrelated mounts. Mount the old Btrfs top level in an isolated rescue tree and inventory nested subvolumes first. If any actual Incus storage uses Btrfs subvolumes rather than `dir`, preserve/reconstruct that structure explicitly; a plain directory copy is not necessarily sufficient.

Budget from actual contents. File copying can expand reflink sharing; virtual disks can have large apparent sizes. Preserve sparse data, exclude unneeded historical snapshots deliberately, and verify pool headroom rather than assuming the original Btrfs used-byte count equals export size.

## Phase 4: export acceptance before any destructive step

- Confirm every required tree was copied without unresolved read errors; review rsync exit status and itemized differences.
- With the source stable/read-only, checksum-compare source and destination (`rsync -aHAXSnci --numeric-ids` with the same deliberate exclusions, plus manifest checks).
- Verify the saved host public key matches the registry identity without printing its private key; test backup-key availability independently of eihort.
- Check PostgreSQL cluster/WAL/tablespace completeness. Perform crash recovery and representative queries on a writable **copy/clone** with the matching PostgreSQL 17 and extensions, protecting original tablespace datasets. Do not use the original as the validation scratch cluster.
- Check representative Incus disks/root filesystems and database/identity files. Inspect source symlinks for paths into `/nix/store` or external datasets.
- Snapshot the verified export and record dataset names, manifests, checksums and any accepted omissions.

Only after acceptance is it reasonable to replace the NVMe filesystem. A completed file copy alone does not establish application consistency after hard resets. If a required file/database cannot be recovered, resolve that gap or explicitly accept its loss before formatting the original member.

### Optional full-filesystem rollback copy, recommended if capacity permits

Keeping the staging ZVOL alone does **not** preserve the old filesystem after overwriting its NVMe member. To preserve that fallback, after ZFS log recovery and with the old Btrfs/raw partition held read-only, snapshot the staging ZVOL and save a verified raw image of the NVMe data partition into the encrypted export dataset. The pair preserves both members at a stable recovery point.

The raw image adds approximately 444.4 GiB before compression and another sequential read/write pass; measure space and throughput first. Keep the staging key/header and verify the raw-image size and checksum. This adds no hardware, and is preferred if the available pool space permits it. If omitted to minimize copying, explicitly treat the verified file export as the recovery authority once the NVMe is formatted; the leftover staging device is only a partial old filesystem.

## Phase 5: initialize and install only on the NVMe target

1. Unmount the old Btrfs so the NVMe is no longer an active member. Leave the source staging ZVOL and verified backup intact. Do not remove/destroy them.
2. Update `mod/disko/eihort.nix`: retain tmpfs `/`; put the `nix`, `persist` and `var` subvolumes inside one LUKS container. Keep the existing HDD ZFS pool out of Disko formatting.
3. Prefer reusing the existing GPT/ESP and formatting only the verified NVMe data partition; there is no need to repartition the entire machine. If a generated Disko formatting workflow is chosen instead, review its complete target list and effects first. Do not accidentally include the ZFS cache NVMe or SATA DOM.
4. Initialize a fresh LUKS2 container with independent final credentials, offline recovery material and a new offhost header backup. The source staging key is not the final recovery passphrase.
5. Retain the requested hastur alignment: AES-XTS 512-bit volume key, 512-byte encryption sectors, 16 MiB offset; `allowDiscards=true`, `bypassWorkqueues=true`, and crypttab options `same-cpu-crypt` / `submit-from-crypt-cpus`. Hardware-specific TPM/FIDO options remain a separate decision.
6. Create new Btrfs with a **new filesystem UUID** and subvolumes; mount it under the installer root alongside tmpfs `/` and the preserved ESP.
7. Configure both swap devices for random per-boot encryption and remove resume configuration. Handle residual plaintext deliberately; `luksFormat` alone is not a data wipe.
8. Use the same configuration/lockfile, PostgreSQL major and service versions. Do not combine recovery with package upgrades.

Native ZFS encryption used for the export is a backup-storage choice. This phase does not encrypt the pre-existing application datasets on `pool0`; migrating that pool is separate work.

## Phase 6: restore before first application start

Restore `var` and `persist` into their new mounts, preserving numeric IDs and identity files. Keep the primary user `elen`; preserve its existing `/var/lib/nixos` and `/var/lib/userborn` identity state. Do not start an empty database cluster or allow applications to initialize empty production state before restoration.

Either reuse a correctly exported/registered Nix store or reinstall it cleanly from the pinned flake; avoid combining a stale database with an unrelated new store. Validate restored profiles and links to store paths.

Check the existing ZFS application dataset mountpoints and PostgreSQL tablespace targets before enabling services. Copying Btrfs `var` does not copy the mounted contents of `pool0/sea-volume`, `pool0/clickhouse`, `pool0/relation`, `pool0/storage`, or the iSCSI ZVOL.

The final initrd must open the new NVMe LUKS before mounting `/nix` and `/persist`. Per the operator's subsequent preference, use the enrolled standard recovery key at the BMC/local console, without initrd SSH or its network/key setup. Livecd SSH remains a separate maintenance channel. Do not make the independent, still-unverified unlock-gate deployment a dependency of the first recovered boot.

Install and verify the new kernel/initrd/bootloader artifacts, including signatures if Secure Boot is enabled. The old initrd is insufficient. Ensure signing/decryption material can be obtained from the restored host identity. Keep the ISO available until boot is verified.

Start PostgreSQL and critical services in a controlled sequence, perform crash recovery/queries and application checks, then test a planned reboot and manual unlock. Re-enable Secure Boot if it was temporarily disabled. Keep the verified export snapshot and old staging ZVOL until data and boot acceptance are complete.

## Expected cost and decision boundaries

- Additional hardware: none for the proposed same-pool export.
- Storage: one independent copy of required persistent data plus reconstruction overhead; approximately 444.4 GiB more if retaining the recommended raw-NVMe image. Measure after rescue mounting. Pool failure remains a shared risk.
- Time: ISO boot and diagnosis, one export, checksum verification, NVMe initialization/install, and one restore. At a sustained 50–100 MiB/s, copying 300 GiB takes roughly 0.85–1.7 hours **per pass**; shared HDD-pool reads/writes, metadata, verification and database recovery can take longer. Do not promise a total duration before observing rescue throughput.
- Current active work: resume the original offline migration, as subsequently requested by the operator. This extraction/reinstall workflow remains a fallback; its destructive reinitialization is not active.
