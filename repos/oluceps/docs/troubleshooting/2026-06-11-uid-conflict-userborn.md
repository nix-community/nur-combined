# Troubleshooting Guide: UID Conflict with Userborn

## Problem
A new machine bootstrap or configuration change fails with `linger-users.service` (or other user-dependent services) reporting that a user does not exist, even though it's defined in the NixOS configuration.

### Symptoms
- `systemctl status linger-users.service` shows: `Failed to look up user <new-user>: No such process`.
- `journalctl -u userborn.service` shows: `Failed to create user <new-user>: ... User with UID 1000 already exists`.
- `id <new-user>` returns nothing, but `id <old-user>` (often `riro` or `elen`) shows UID 1000.

## Root Cause
The project uses `services.userborn` for user management. When switching the primary user (`identity.user`) or re-bootstrapping a disk with an existing `/var/lib/nixos` state, `userborn` may find that the UID (usually `1000`) is already allocated to a different username in its persistent database.

Because the user database files are often bind-mounted and busy, a simple `sed` or `usermod` might fail with `Device or resource busy` or `Read-only file system`.

## Solution (The "Nuclear" Fix)
If you cannot rename the user via standard tools, you must clear the stale persistent state on the target machine.

1.  **SSH into the target machine as root.**
2.  **Force unmount and delete the stale database:**
    ```bash
    # Lazy unmount the locked files
    umount -l /var/lib/nixos/passwd /var/lib/nixos/group /var/lib/nixos/shadow || true
    
    # Delete the persistent database files to let userborn recreate them
    rm /var/lib/nixos/passwd /var/lib/nixos/group /var/lib/nixos/shadow || true
    ```
3.  **Reboot the machine:**
    ```bash
    reboot
    ```
4.  **Verify after reboot:**
    ```bash
    id <new-user>
    systemctl status userborn.service
    systemctl status linger-users.service
    ```

## Prevention
When re-installing or significantly changing user identity on a node, ensure `/var/lib/nixos` is wiped along with the rest of the system state, or explicitly handle the UID migration if preserving data.
