---
name: impermanence
description: Ephemeral root filesystem patterns on NixOS — tmpfs root, btrfs/ZFS rollback-to-blank, environment.persistence, and what must be persisted to stay usable.
---

# Impermanence / Ephemeral Root

Goal: `/` starts clean on every boot. Only an explicitly declared set of paths under `/persist` (or similar) survives. Everything else — leftover files, stale configs, forgotten mutations — is wiped. Forces state to be either in Nix config or explicitly declared as persistent.

## Three common approaches

| Approach | Root filesystem | Wipe mechanism | Trade-offs |
|---|---|---|---|
| **tmpfs root** | `/` on tmpfs (RAM) | Naturally empty every boot | Fastest, but root size limited by RAM; `/nix` must be separate |
| **btrfs rollback** | `/` on btrfs subvolume | `btrfs subvolume delete` + restore from `@root-blank` snapshot | Works on any disk size; survives reboots without RAM pressure |
| **ZFS rollback** | `/` on ZFS dataset | `zfs rollback -r tank/root@blank` | Same as btrfs but via ZFS; requires ZFS kernel module in initrd |

The tmpfs variant is the simplest. The btrfs and ZFS variants are picked when root must be disk-backed (low-RAM machines, very large config closures, crash-dump survivability). Pick based on the machine, not dogma.

## tmpfs root (simplest)

```nix
fileSystems."/" = {
  device = "none";
  fsType = "tmpfs";
  options = [ "defaults" "size=2G" "mode=755" ];
};

# /nix MUST be a persistent filesystem — Nix store must survive
fileSystems."/nix" = {
  device = "/dev/disk/by-label/nixos";
  fsType = "btrfs";
  options = [ "subvol=@nix" "compress=zstd" "noatime" ];
};

fileSystems."/persist" = {
  device = "/dev/disk/by-label/nixos";
  fsType = "btrfs";
  options = [ "subvol=@persist" "compress=zstd" "noatime" ];
  neededForBoot = true;   # CRITICAL — bind mounts from here run before stage-2
};

fileSystems."/boot" = {
  device = "/dev/disk/by-label/ESP";
  fsType = "vfat";
};
```

## btrfs rollback-to-blank (disk-backed root)

One-time: after initial install, snapshot the empty `@root`:
```bash
mount -o subvol=/ /dev/mapper/cryptroot /mnt
btrfs subvolume snapshot -r /mnt/@root /mnt/@root-blank
umount /mnt
```

Then wipe on every boot with an initrd systemd service:
```nix
boot.initrd.systemd.services.rollback-root = {
  description = "Roll back btrfs root to blank snapshot";
  wantedBy = [ "initrd.target" ];
  after = [ "cryptsetup.target" ];   # drop if disk is unencrypted
  before = [ "sysroot.mount" ];
  unitConfig.DefaultDependencies = "no";
  serviceConfig.Type = "oneshot";
  script = ''
    mkdir -p /mnt
    mount -o subvol=/ /dev/mapper/cryptroot /mnt

    # Delete nested subvolumes under @root first, otherwise delete fails
    ${pkgs.btrfs-progs}/bin/btrfs subvolume list -o /mnt/@root |
      cut -f9 -d' ' |
      while read sv; do
        ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "/mnt/$sv" || true
      done

    ${pkgs.btrfs-progs}/bin/btrfs subvolume delete /mnt/@root
    ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot /mnt/@root-blank /mnt/@root
    umount /mnt
  '';
};
```

Requires `boot.initrd.systemd.enable = true;` — scripted initrd cannot do this cleanly.

## ZFS rollback-to-blank

Analogous:
```nix
boot.initrd.postDeviceCommands = lib.mkAfter ''
  zfs rollback -r tank/root@blank
'';
```
Create the `@blank` snapshot once, right after installation, before first real boot.

## Declaring what survives — `nix-community/impermanence`

Add input:
```nix
inputs.impermanence.url = "github:nix-community/impermanence";
# In module imports:
imports = [ inputs.impermanence.nixosModules.impermanence ];
```

Then declare what to bind-mount back from `/persist`:
```nix
environment.persistence."/persist" = {
  hideMounts = true;     # don't clutter `mount` output
  directories = [
    "/var/log"
    "/var/lib/nixos"             # user UIDs, counter state — NEEDED or users drift
    "/var/lib/systemd/coredump"
    "/etc/NetworkManager/system-connections"
    # Service data you want to keep:
    # "/var/lib/postgresql"
    # "/var/lib/docker"
  ];
  files = [
    "/etc/machine-id"            # NEEDED — journald/systemd rely on stable ID
    "/etc/adjtime"
  ];

  users.alice = {
    directories = [
      ".ssh"
      ".config"
      ".local/share"
      { directory = ".gnupg"; mode = "0700"; }
    ];
    files = [ ".bash_history" ];
  };
};
```

The module creates bind mounts from `/persist/var/log → /var/log` early in stage-2, before services start.

## Paths you must almost always persist

| Path | Why |
|---|---|
| `/etc/machine-id` | journald, systemd timers, D-Bus — changing it per boot breaks log continuity and ID-based state |
| `/etc/ssh/ssh_host_*_key*` | Or fresh host keys every boot → clients scream `REMOTE HOST IDENTIFICATION HAS CHANGED` |
| `/var/lib/nixos` | Stable UID/GID allocation — omit this and user numbers shuffle between boots |
| `/var/log` | Obvious; also journald needs a persistent `/var/log/journal` for non-volatile logs |
| `/var/lib/systemd/timers` | Persistent timer last-run state |
| `/var/lib/bluetooth` | Paired device database |
| `/var/lib/tailscale` | Node identity / node key — losing this re-registers the node |
| Service state dirs | `/var/lib/<service>` for anything stateful you run (postgres, docker, samba, transmission, …) |

## SSH host keys — two options

1. Persist `/etc/ssh` as a directory under `environment.persistence` — simple, but first boot generates fresh keys.
2. Install specific host keys during `nixos-install` so identity is fixed from day one:
   ```bash
   mkdir -p /mnt/persist/etc/ssh
   cp ssh_host_ed25519_key     /mnt/persist/etc/ssh/
   cp ssh_host_ed25519_key.pub /mnt/persist/etc/ssh/
   chmod 600 /mnt/persist/etc/ssh/ssh_host_*_key
   ```
   Pair with `services.openssh.hostKeys` pointing at those paths (or rely on the default paths once bind-mounted).

## Interactions that bite

- **`users.mutableUsers = true` + impermanence**: `passwd` writes go to `/etc/shadow`, which is on tmpfs/ephemeral root. On reboot the new password is gone. Either set `mutableUsers = false` with `hashedPassword`/`hashedPasswordFile`, or persist `/etc/shadow` (not recommended — creates a race with NixOS generation).
- **`neededForBoot = true` on `/persist`**: without it, bind mounts from `environment.persistence` race the mount and produce empty dirs.
- **First boot after switching to impermanence**: anything that was in `/` outside `/persist` is gone. Plan migration — copy existing state into `/persist` *before* the rebuild that enables rollback.
- **`/tmp` on tmpfs**: already handled by `boot.tmp.useTmpfs = true` — don't double-declare.
- **Nested btrfs subvolumes under `@root`**: Docker, libvirt, some container tools create subvolumes inside `/var/lib/...`. If `/var/lib/docker` isn't persisted, the rollback script must delete these nested subvolumes before deleting `@root` — otherwise btrfs refuses.

## Verifying ephemerality works

Write a marker file, reboot, check it's gone:
```bash
touch /root/SHOULD_BE_WIPED
reboot
# after reboot:
ls /root/SHOULD_BE_WIPED   # expect: No such file or directory

# Meanwhile persisted data:
ls /persist/var/log        # expect: real log files
```

If the marker survives, the rollback didn't run — check `journalctl -b -u rollback-root` or `dmesg | grep rollback`.

## Signals you're over- or under-persisting

**Over-persisting** (you've effectively disabled impermanence):
- `/persist` mirrors most of `/var` and `/etc`
- Forgotten config changes stick around across reboots
- Rollback becomes "pointless" — you're persisting the bugs you wanted to wipe

**Under-persisting** (users/services misbehave):
- SSH host key warning on every deploy
- UIDs/GIDs of services shift between boots → wrong file ownership
- `hostnamectl` loses machine-id; `systemd-journald` starts a fresh log every boot
- Tailscale re-registers the node each reboot

Start minimal (`/etc/machine-id`, `/var/lib/nixos`, `/var/log`, SSH host keys, your service data dirs). Add more only when you can name a specific symptom a missing path caused.
