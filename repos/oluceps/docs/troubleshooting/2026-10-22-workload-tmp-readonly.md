# Troubleshooting Guide: Read-Only `/tmp` Inside a Realm Workload

## Problem

An application that runs inside a Realm private network namespace cannot write
temporary files. Meilisearch reported this on `eihort`:

```
ERROR HTTP request{method=POST route=/indexes/.../documents status_code=500
error=Error while receiving the playload. `Read-only file system (os error 30)`.}
```

Reading from the index still worked. Only requests that spool the request body
to a temporary file failed, so the symptom looked like a payload problem
instead of a sandbox problem.

## Symptoms

- The unit file contains `PrivateTmp=true`, yet the process sees the host
  `/tmp`, including files created by other units.
- Writes to `/tmp` fail with `EROFS`:

  ```sh
  pid=$(systemctl show meilisearch -p MainPID --value)
  nsenter -t "$pid" -m -- touch /tmp/x   # Read-only file system
  ```

- `strace` on the process shows the failing call directly:

  ```
  openat(AT_FDCWD, "/tmp", O_RDWR|O_CLOEXEC|O_TMPFILE, 0666) = -1 EROFS
  ```

- `/proc/<pid>/mountinfo` lists `/tmp` as the host mount with the `ro` flag and
  no `systemd-private-.../tmp` mount beneath it.

## Root Cause

`systemd` 261.2 does not mount the `PrivateTmp` tmpfs for a unit that joins
another unit's network namespace. Every application unit here joins
`realm-net-<name>.service` through `JoinsNamespaceOf=`, so `PrivateTmp` never
takes effect. The unit keeps the host `/tmp`, which `ProtectSystem=strict` has
already remounted read-only.

`PrivateMounts=yes` does not change this. Only an explicit tmpfs mount does.

Reproduce with transient units:

```sh
systemd-run --quiet --collect --unit=hold-probe.service \
  --property=PrivateNetwork=yes /run/current-system/sw/bin/sleep infinity

# PrivateTmp alone works, and yields an empty /tmp.
systemd-run --quiet --collect --unit=pA.service \
  --property=PrivateTmp=yes --property=ProtectSystem=strict \
  /run/current-system/sw/bin/sh -c 'ls -A /tmp | wc -l; touch /tmp/x && echo ok'

# Joining the holder's netns loses the private tmpfs, so /tmp is the host /tmp
# and it is read-only.
systemd-run --quiet --collect --unit=pB.service \
  --property=PrivateTmp=yes --property=ProtectSystem=strict \
  --property=JoinsNamespaceOf=hold-probe.service --property=PrivateNetwork=yes \
  /run/current-system/sw/bin/sh -c 'ls -A /tmp | wc -l; touch /tmp/x || echo EROFS'
```

## Fix

`nixosModules/realm-workloads.nix` mounts a tmpfs for `/tmp` explicitly, both in
the shared hardening set and in the application unit that overrides its
`TemporaryFileSystem` list. The result is private and writable, and it no longer
exposes host `/tmp` contents to the workload.

The mount needs `mode=1777`. A bare `TemporaryFileSystem=/tmp` creates a
root-owned `0755` tmpfs, and a service that runs as an unprivileged user then
fails with `permission denied`. `ncps` reported exactly that:

```
error setting cache temp dir: error verifying tmp directory is writable:
open /tmp/boot_test1387518892: permission denied
```

Do not work around this with `ReadWritePaths = [ "/tmp" ]`. That path is the
host `/tmp` in this situation, so the setting removes the isolation instead of
restoring temporary storage. Worse, a `ReadWritePaths` entry for `/tmp` also
cancels the explicit tmpfs for that path, so the unit keeps a writable host
`/tmp` while its unit file appears to request a private one. `ncps` and
`seaweedfs` used that workaround and no longer need it.

## Verification

```sh
pid=$(systemctl show meilisearch -p MainPID --value)
grep -E ' /tmp ' /proc/"$pid"/mountinfo          # tmpfs, rw, no host contents
nsenter -t "$pid" -m -- ls -A /tmp                # empty
nsenter -t "$pid" -m -- touch /tmp/probe && echo writable
```

`tests/realm-vm.nix` covers both halves: a host file in `/tmp` stays invisible
to the `sender` workload, and the workload can create its own file there.
