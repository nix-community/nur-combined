# eihort: online Btrfs to LUKS migration

Status recorded: 2026-11-19. Both Btrfs evacuations completed and were independently verified. The final return finished at 12:11:18 +08:00 (04:11:18 UTC); encrypted NVMe mapper `cryptroot`, device 3, is the sole member, retaining filesystem UUID `736e050f-7171-489c-9567-e5385e9c2e04` and the existing subvolumes. All device error counters are zero and `pool0` is healthy. Staging remains available but is no longer a member. The final volume has one standard systemd recovery credential, verified against the volume and updated header backup. Per operator preference, no initrd SSH/network unlock is configured, and eihort now declares ordinary systemd-boot with its `secureboot` import commented out. Generation 1312 using ordinary systemd-boot was installed offline and its ESP kernel/initrd were compared byte-for-byte with the built artifacts. First encrypted boot succeeded: the operator's IPMI console was used to submit the standard recovery key, production SSH returned at approximately 13:10 +08:00, and the system reached `running` with no failed units. Final checks at 13:14:52 +08:00 confirmed the expected generation, encrypted persistent mounts and both encrypted swap mappings, healthy `pool0`, PostgreSQL readiness and the running Incus instance. Secure Boot and watchdogs remain disabled as configured.

Update 2026-11-19 14:40 +08:00: network-bound unlock is now deployed on top of this layout (`mod/nbde.nix`, design in `docs/draft/unlock-gate.md`). Keyslot 0 holds a random 64-byte key whose clevis JWE (`/persist/keys/crypt-root.jwe`, 2-of-3 across the unlock-gates on yidhra, abhoth and nodens) is copied into the initrd; nbde-agent unlocks `cryptroot` over the initrd network on eno1. The recovery key in slot 2 remains the fallback, prompted for after the agent's deadline. A planned reboot through `eihort-reboot` unlocked unattended on the first try. The statements below about no initrd network unlock describe the state before that change.

## Configuration source

`mod/disko/eihort.nix` defines the disk layout. Its `root` partition now wraps the existing `nix`, `persist`, and `var` Btrfs subvolumes in LUKS mapper `cryptroot`; `/` remains tmpfs. The subvolumes, mount options, partition table and ESP are preserved. Host-specific Disko modules are imported automatically by `mod/os.nix`.

Do not run Disko's formatting workflow on the existing installation. Declaring the desired layout does not migrate its data.

## Verified source state

- Source partition: `/dev/disk/by-id/nvme-eui.00000000000000008ce38e10014c244a-part3` (currently `/dev/nvme1n1p3`).
- Source partition size: 477,212,180,480 bytes.
- Btrfs UUID: `736e050f-7171-489c-9567-e5385e9c2e04`.
- Initially one Btrfs device; now two devices after staging add, data `single`, metadata/system `DUP`.
- Subvolume IDs: `nix=256`, `persist=257`, `var=260`; nested snapshots also exist.
- Device error counters were all zero; last completed scrub reported no errors.
- No balance or device replacement was running.
- Btrfs has only 1 MiB of unallocated device space despite approximately 61 GiB estimated free space within allocated chunks. Do not assume an immediate shrink is possible.
- Kernel 6.18.54, btrfs-progs 7.1, cryptsetup 2.8.7.
- Secure Boot enabled in user mode, lanzaboote/systemd-boot; no TPM2 reported.
- `/nix`, `/persist`, and `/var` are needed during early boot. A tmpfs root does not make the system independent of the Btrfs device.

## Completed: encrypted staging device

Created a new ZVOL and LUKS mapping without touching the source partition:

| Property | Value |
| --- | --- |
| ZVOL | `pool0/eihort-luks-stage` |
| Stable device | `/dev/zvol/pool0/eihort-luks-stage` |
| Open mapper | `/dev/mapper/eihort-btrfs-stage` |
| ZVOL size | 483,183,820,800 bytes (450 GiB) |
| ZVOL refreservation | 490,743,267,328 bytes, including ZFS overhead |
| ZVOL block size | 16 KiB |
| Compression / sync | `off` / `standard` |
| LUKS UUID | `5488d99b-a4f2-4cf9-9ec0-e0938eb0bade` |
| Cipher / key size | AES-XTS / 512 bits |
| Encryption sector size | 512 bytes, matching hastur |
| Actual payload offset | 16,777,216 bytes (16 MiB), matching hastur |
| Actual mapper size | 483,167,043,584 bytes |

The mapper is open and was added to the existing Btrfs as device 2 at 16:48:10 +08:00. The original raw NVMe remains device 1. No independent filesystem was created on the staging mapper; neither staging nor final mapper should be independently formatted with `mkfs.btrfs` for this migration.

The executed add operation was:

```sh
btrfs device add --nodiscard /dev/mapper/eihort-btrfs-stage /persist
btrfs filesystem sync /persist
```

The new mapper was already verified empty; `--nodiscard` avoided an unnecessary whole-device discard during addition. The mapping still permits normal discards, matching hastur. Immediately after adding, device 2 had no allocated chunks; existing data was still on the NVMe. New writes may allocate staging space without an explicit balance or removal.

Both devices' error counters remained zero after addition. `/nix` and `/var` remained mounted and systemd reported `running`. No balance was started. Source evacuation was subsequently started as described below. Treat both devices as required until successful removal is independently verified: do not close/reformat staging or assume the existing boot configuration can recover the mixed-device state.

Checks completed:

- Verified pool health, source membership, unused names, raw size, and non-sparse reservation.
- Created a fresh random staging unlock key on hastur, outside the repository.
- Authenticated the key and actually closed/reopened the staging mapper.
- Copied the 16 MiB LUKS header backup to hastur and checked its SHA-256 against the remote copy.
- Authenticated the key using the backup header.
- At preparation, rechecked the single source device with all error counters zero; after the subsequent add, verified both members and all error counters again.

Private recovery files are on hastur's encrypted persistent filesystem:

- Directory: `/home/riro/.local/state/eihort-luks/2026-11-18/` (mode `0700`).
- `stage.key`: binary 64-byte unlock key, mode `0600`.
- `stage.header`: LUKS header backup, mode `0600`.
- `staging-ready.json`, `verification.txt`, and preparation records contain the non-secret status and checks.
- The preparation script is `/home/riro/.local/state/eihort-luks/prepare-stage.py`. It intentionally refuses to re-run once its key file exists, to prevent accidental reformatting.

No plaintext key file was created on eihort. Existing eihort swap remains unencrypted; key handling and residual swap contents must be addressed before treating the completed migration as protecting offline disk contents.

The initial empty staging header used 4 KiB sectors and a 32 MiB offset. Before adding any filesystem data, the unused staging ZVOL was reformatted to match hastur's actual 512-byte sectors and 16 MiB offset. Its new header backup replaced the active offhost backup; the unused initial header and metadata remain archived separately. All close/reopen and header checks were repeated.

### Alignment with hastur

Read both `mod/disko/hastur.nix` and the live `cryptroot` mapping/header. The staging mapping now has exactly the same five active dm-crypt flags:

```text
discards same_cpu_crypt submit_from_crypt_cpus no_read_workqueue no_write_workqueue
```

The LUKS header stores the same three persistent flags as hastur: `allow-discards`, `no-read-workqueue`, and `no-write-workqueue`. The other two flags must be supplied again when opening the mapping, as they are by hastur's crypttab configuration.

Use these equivalent settings when declaring eihort's final LUKS container in `mod/disko/eihort.nix`:

```nix
settings = {
  allowDiscards = true;
  bypassWorkqueues = true;
  crypttabExtraOpts = [
    "same-cpu-crypt"
    "submit-from-crypt-cpus"
  ];
};
```

These settings control activation, not the format operation. For the eventual final NVMe container, explicitly retain LUKS2, AES-XTS with a 512-bit volume key, 512-byte encryption sectors, and a 16 MiB payload offset. Measure the resulting mapper instead of assuming its size.

Hastur additionally requests `fido2-device=auto`, `tpm2-device=auto`, and `tpm2-measure-pcr=yes`, and its live header has registered FIDO2, TPM2, and recovery tokens. Those are hardware unlock/PCR policies, not data encryption format parameters. Eihort reports no TPM and its proposed unlock-gate flow is a separate policy; do not silently enable those host-specific mechanisms as part of format alignment.

The Disko declaration now leaves format defaults to Disko/cryptsetup, as on hastur: explicit `extraFormatArgs`, including the custom LUKS label, have been removed. Those options only affect a future format operation. Opening the existing volume reads its cipher, sector size and offset from the LUKS header, so removing the declaration does not change the current 512-byte sectors, 16 MiB offset or existing on-disk label. Future format defaults may differ; do not use Disko's formatting workflow on this installation.

`fido2-device=auto` is now also present in `crypttabExtraOpts`, alongside `same-cpu-crypt` and `submit-from-crypt-cpus`. No FIDO2 credential has been enrolled; the sole active unlock credential remains the standard recovery key. No TPM settings are copied. At the operator's request, the host uses ordinary systemd-boot with Secure Boot disabled; Secure Boot itself does not require a TPM.

Hastur's current hardware-token keyslots use PBKDF2/SHA-512 with 1,000 iterations. Those keyslot parameters were not copied. Staging retains Argon2id (maximum 256 MiB, two threads, approximately one-second target) for its independent random unlock key; manual passphrase slots on the final volume also need an appropriate passphrase KDF.

## Backup coverage established during preparation

The running rustic profiles were parsed without printing repository credentials. `on-hastur`, `on-eihort`, and `on-coldarch` each explicitly back up `/var/lib/backup/postgresql/all.sql`; `general` supplies `one-file-system=true` and does not add full filesystem coverage.

The latest recorded PostgreSQL export and rustic backup/check completed successfully. This is **not** a verified backup of `/persist`, `/var`, or all services. Full persistent-file backup and independent boot recovery remain outstanding after the explicitly requested device add. A second device participating in the same Btrfs is not a backup.

## Preparation backup and boot recovery checklist

This was the preparation checklist. The independent rescue boot, final console recovery-key boot and encrypted swap have since been verified. Complete independent persistent-file backup coverage remains outstanding.

1. Establish and verify file-data backup coverage beyond the PostgreSQL dump; explicitly handle nested Btrfs subvolumes and application consistency.
2. Prepare a recovery environment independent of the source `/nix`, with compatible ZFS, cryptsetup, Btrfs, network tools, and access to both stage/final unlock credentials.
3. Account for Secure Boot when selecting or signing rescue media. Building or signing an image alone does not establish that it boots on this machine.
4. Ensure the recovery environment can import `pool0`, expose the staging ZVOL, open its LUKS mapping, and mount Btrfs. The current stage-2 `zfs-import-pool0.service` is not evidence that the initrd can do this. A compatible minimal NixOS recovery image needs its own store/tools. The repository's existing `rescue` host initially used a no-ZFS installer; it has now been updated to the compatible kernel and ZFS-capable installer. The ordinary installer ISO is not automatically signed by Lanzaboote. A signed recovery initrd must deliberately remain in stage 1 with working device/network/console access. The updated rescue ISO has now been built, mounted through BMC, booted by the operator and accessed over SSH. Hardware watchdog disarm and access to both old Btrfs members have been verified.
5. Prepare the final LUKS boot configuration and a fallback unlock route. The independent unlock-gate draft is not deployed to eihort.
6. Plan and complete encrypted swap handling, including old plaintext contents and removal of `resumeDevice`. The NVMe swap held about 16 GiB at preparation; do not use `swapoff -a` on this busy host.

## Historical: online source evacuation

Started at 2026-11-18 16:52:04 +08:00, independently of SSH:

- Unit: `eihort-btrfs-evacuate.service`.
- Script: `/run/eihort-luks-prep/evacuate-nvme.sh`; offhost copy alongside the private migration records on hastur.
- Log: `/var/log/eihort-luks-migration/evacuate-nvme.log` (root-only).
- Action: `btrfs device remove /dev/disk/by-id/nvme-eui.00000000000000008ce38e10014c244a-part3 /persist`.
- Scheduling: nice 10, I/O weight 50; no service runtime limit or automatic retry.
- On success: sync, require exactly one member matching the staging mapper, check device error counters, then write `/var/log/eihort-luks-migration/evacuate-nvme.completed`.
- There is no formatting, key change, or next migration step in this service.

The first progress check showed the removal process active and kernel messages for relocating data block groups and updating extent pointers. Device error counters remained zero and the ZFS pool remained healthy. One corrected ECC event was logged during the initial sample; the controller counters at 16:53:34 were 124 corrected and zero uncorrected errors in total. No pre-operation ECC counter baseline was captured, so the cumulative count must not be attributed to this migration. During removal, `btrfs device usage` can show the source's size as slack and negative unallocated space while its temporary Btrfs device size is zero; that output alone is not evidence that evacuation has finished.

Inspect progress with `systemctl status eihort-btrfs-evacuate.service`, the log above, `btrfs device usage -b /persist`, and `btrfs device stats --check /persist`. A running service's `Result=success` / `ExecMainStatus=0` is not a completion check. Verify service exit and actual membership before reusing the source partition.

## Offline recovery and resumed evacuation

The ISO is reachable by SSH as `root@192.168.0.20`; the local SSH host-key alias is `eihort-rescue-20261118`. The operator temporarily disabled Secure Boot to boot this unsigned ISO.

Validated in rescue:

- Kernel 6.18.54, ZFS 2.4.4 module/userspace, btrfs-progs 7.1, cryptsetup 2.8.7.
- Hardware watchdog read back `Stopped`; systemd runtime/reboot watchdog values are zero.
- No swap; approximately 30 GiB initially available RAM, 26 GiB after starting recovery work.
- Pool GUID `12308897696819484456` imported with `-N`, `cachefile=none` and an alternate root. `-f` handled the changed livecd host ID after the original host had stopped. All pool members were ONLINE with no known errors; application datasets stayed unmounted.
- Raw NVMe initially set block-read-only and staging opened read-only; mounted `ro,rescue=nologreplay,subvolid=5`. Standalone `nologreplay` is not accepted by this kernel's mount parser.
- Both members and `var`/`persist`/`nix` were present. Source superblock flags were `WRITTEN` only, `log_root=0`; all device error counters zero.
- Kernel `state E` on the rescue mount was verified against upstream 6.18.54: `rescue=nologreplay` intentionally sets in-memory `fs_error=-EROFS` to block transactions. It is not, by itself, proof of corruption.
- A 40 KiB archive of `var/lib/ssh`, `var/lib/nixos`, and `var/lib/userborn` was saved on hastur as `rescue-critical-identity.tar` in the private migration directory. It contains private identity material and must not enter the repository. The SQL dump is approximately 34.3 GB, not part of this small archive.
- The rescue mount was fully unmounted; staging closed/reopened writable and the raw read-only flag cleared; a fresh normal RW mount and filesystem sync succeeded without actual filesystem errors.
- Rescue ARC bounds: minimum 1 GiB, maximum 8 GiB. ECC corrected/uncorrected counts were both zero during the initial recovery check.

Resumed task:

- Unit: `eihort-btrfs-evacuate-offline.service`; script `/run/eihort-rescue/evacuate-nvme.sh`.
- Mountpoint: `/mnt/eihort-old` (Btrfs top level).
- Log: `/run/eihort-rescue/evacuate-nvme.log`.
- Started 13:10:17 UTC / 21:10:17 +08. The actual removal process and block-group relocation messages were observed.
- Initial remaining NVMe allocation: 172,910,182,400 bytes (about 161 GiB); staging allocation: 235,216,568,320 bytes.
- On success, sync and require staging as sole member, then save `/run/eihort-rescue/evacuate-nvme.completed` and `var/log/eihort-luks-migration/evacuate-nvme-offline.completed` in the old filesystem.
- No business services, automatic retry, formatting, or next-stage encryption are included in this task.

Completed at 2026-11-18 16:19:20 UTC / 2026-11-19 00:19:20 +08:00, approximately 3 hours 9 minutes after offline resumption. The completion marker, final kernel `device deleted` message, and independent membership check agree. Device 2 is the sole member and the raw NVMe has no remaining filesystem signature. The old subvolumes remain mounted RW at `/mnt/eihort-old` through staging. At the later status check, all Btrfs device counters remained zero, ZFS reported healthy, hardware watchdog remained stopped, and swap remained disabled. ECC counters since this rescue boot were 8 corrected and zero uncorrected errors.

## Final NVMe initialization and return migration

After sole-staging membership was reverified, only the detached NVMe data partition was logically discarded and initialized as LUKS2. GPT and ESP UUID comparisons were unchanged.

- Raw target: `/dev/disk/by-id/nvme-eui.00000000000000008ce38e10014c244a-part3`.
- Final mapper: `/dev/mapper/cryptroot`.
- Final LUKS UUID: `2c86143d-4582-41b3-9afb-b5ee58032874`.
- Data format: AES-XTS 512-bit volume key, 512-byte sectors, 16 MiB offset; mapper size 477,195,403,264 bytes.
- Runtime flags match hastur: discards, same CPU, submit from crypt CPUs, and both workqueue bypasses.
- A standard `systemd-cryptenroll --recovery-key` credential is enrolled as the sole active keyslot (slot 2), with a `systemd-recovery` token. It was tested with cryptsetup and the updated backup header before the temporary ordinary slots 0/1 were retired.
- The recovery key is `/home/riro/.local/state/eihort-luks/2026-11-18/root-recovery.key` on encrypted hastur; the current backup header is `root.header` in the same private directory. Both have mode `0600`. Initial credentials/header are archived separately and are no longer active on the volume. No unlock material enters the repository, Nix store, initrd or ESP.
- Initrd SSH, its network configuration, and the unused dedicated initrd identity were removed at the operator's request. First boot uses the BMC/local console recovery key. Livecd SSH remains available for maintenance.
- Both old inactive swap areas were logically discarded at 00:44:22 UTC; the declarative system uses fresh random encryption on each boot and no resume device.
- The final ordinary-systemd-boot console-unlock generation built successfully at `/nix/store/ins675r46v7sp4l8wxf3h5dgmv6rcb8b-nixos-system-eihort-26.11.20260926.e158d9e`. The `secureboot` import is commented out and the previous eight-generation limit is preserved. Evaluation has no failed assertions, and the built initrd crypttab contains the requested CPU/FIDO2 options plus discard/workqueue settings. It was installed offline as generation 1312 with `nixos-install --system`, with kernel/initrd byte comparisons and default-entry checks passing. Its first encrypted boot was verified through IPMI recovery-key entry and authenticated production SSH; system state is `running` with no failed units. Production watchdogs remain disabled for the ongoing hardware follow-up.

`cryptroot` was added as device 3 without running mkfs.btrfs. Return ran from 08:33:57 to 12:11:18 +08:00 (00:33:57–04:11:18 UTC), taking 3 hours 37 minutes 21 seconds, using `btrfs device remove /dev/mapper/eihort-btrfs-stage /mnt/eihort-old` in `eihort-btrfs-return-nvme.service`. The service exited successfully. Its completion markers, kernel device-deletion message and independent membership check agree: device 3 is the sole member. The filesystem's used bytes were 389,636,669,440 at verification, all device error counters were zero, and the original subvolume IDs and filesystem UUID remain unchanged. `pool0` reported healthy. ECC counters were 9 corrected and zero uncorrected errors; the ninth CE, at 10:39 +08:00, reported `csrow:3 channel:1 syndrome:0x29`, distinct from the preceding eight. Memory maintenance remains outstanding.

Logs and independent verification are saved in the private offhost migration directory (`return-nvme.log`, `return-nvme.completed`, `return-completed-verification.txt`). Staging was neither closed nor destroyed, and no reboot was performed.

## Subsequent migration sequence

Use stable paths and current membership checks at every stage:

1. **Completed 2026-11-18 16:48:10 +08:00:** added the existing staging mapper to the mounted Btrfs as device 2.
2. **Completed 2026-11-19 00:19:20 +08:00:** offline source evacuation succeeded; raw NVMe is no longer a member.
3. **Verified:** sync/completion marker, kernel deletion message, sole staging membership, and zero device error counters.
4. **Completed:** after verifying source evacuation, the detached NVMe data partition was logically discarded and initialized as LUKS2; the standard recovery key and updated header backup were verified offhost.
5. **Completed 2026-11-19 12:11:18 +08:00:** staging device 2 was successfully removed; independent verification confirms device 3 (`cryptroot`) as the sole final member.
6. **Installed and boot-verified:** ordinary-systemd-boot generation 1312 is the default entry. ESP and previous profile links were saved offhost before installation. The ESP has approximately 413 MiB free. Kernel/initrd match the built artifacts, the full closure is registered on the target, and the entry contains no resume device. Lanzaboote is disabled; there are no initrd network/SSH services or embedded unlock secrets. Console recovery-key entry and production boot succeeded; the live system reached `running` with no failed units.
7. Retire the staging ZVOL and temporary credentials only after all checks and boot verification succeed.

No RAID1 conversion is needed for the existing data `single` / metadata `DUP` layout. The filesystem UUID, subvolume IDs, snapshots, and existing mounts remain part of the same filesystem throughout; Btrfs device IDs can change.

## Verified encrypted production boot

- Before reboot, target mounts were synced and cleanly unmounted, staging was closed and `pool0` exported. The staging ZVOL was retained. UEFI BootNext selected the newly installed Linux Boot Manager.
- The new initrd displayed the standard recovery-key prompt for `cryptroot`; IPMI USB keyboard input successfully unlocked it. No recovery key was stored in the initrd, ESP or repository.
- `/run/current-system` matches `/nix/store/ins675r46v7sp4l8wxf3h5dgmv6rcb8b-nixos-system-eihort-26.11.20260926.e158d9e` (generation 1312).
- `/` remains 2 GiB tmpfs; `/nix`, `/persist` and `/var` are RW Btrfs subvolumes on the sole member `cryptroot`. UUID and subvolume IDs are preserved. The five active dm-crypt flags, 512-byte sectors and 16 MiB offset match the prepared final volume. All Btrfs device error counters are zero; no kernel storage errors were observed.
- Both swap devices use active PLAIN dm-crypt mappings with AES-XTS, 256-bit total keys, backed by NVMe partition 2 and the SanDisk DOM. Their live priorities are 100 and 1. These mappings implement the declared per-boot random encryption.
- `pool0` is healthy; its application datasets are mounted. Staging remains unmapped and is not required for boot.
- `systemctl is-system-running` reports `running`, with no failed units or pending jobs. PostgreSQL accepts connections; Incus reports `node-2` RUNNING. Caddy, Forgejo, Immich, Synapse, SeaweedFS and Vaultwarden services are active.
- Current-boot ECC counters were 0 corrected / 0 uncorrected at 13:14:52 +08:00. This resets the counter baseline; it does not erase the prior rescue boot's 9 corrected events. Memory follow-up remains necessary.
- Secure Boot remains off at the operator's request. Hardware watchdogs remain blacklisted, and systemd runtime/reboot watchdog values are zero.
- `btrfs filesystem show` can print `cannot access '/var/lib/nixos/group': Read-only file system` while scanning Userborn's intentionally read-only file bind, then exit successfully. The actual `/var` mount is RW; the live storage checks above show no filesystem/device error.

Private records include the ESP/profile backups, install log, artifact comparison, and `first-boot-live-verification.txt` / `first-boot-service-verification.txt`. The temporary rescue ISO/share and staging ZVOL are retained for follow-up; no staging destruction was performed.

## Recovery dependencies by phase

| Interruption point | Devices to make available before normal mounting |
| --- | --- |
| Before first add (historical) | Original raw NVMe only |
| Source evacuation completed, before final add (historical) | Opened staging mapper only |
| Final added, staging removal running (historical) | Both opened encrypted mappers |
| **Current: staging removal completed** | Final opened NVMe mapper only |

During mixed-device phases, data `single` does not provide cross-device redundancy. Do not plan to mount degraded or format an apparently inactive member. Inspect membership and errors before resuming an interrupted removal.

## References

- [Btrfs mounted device management and original-device removal](https://btrfs.readthedocs.io/en/latest/btrfs-device.html)
- [Btrfs relocation and workspace requirements](https://btrfs.readthedocs.io/en/latest/btrfs-balance.html)
- [LUKS formatting](https://man7.org/linux/man-pages/man8/cryptsetup-luksFormat.8.html)
