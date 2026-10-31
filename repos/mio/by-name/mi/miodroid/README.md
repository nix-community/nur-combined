# Miodroid

Miodroid packages Waydroid with separate executable, service, D-Bus, desktop,
and state names so it can be installed alongside upstream Waydroid. The runtime
is based on Waydroid 1.6.3, with the community multi-instance and vendor-detection
patches attributed in `package.nix`.

## Rootful

Enable `virtualisation.miodroid.enable` in NixOS. The system container manager
uses the system bus; start the desktop session as your normal desktop user with
`miodroid session start`. The default image bundle is built with Robotnix from
pinned LineageOS 20 / Waydroid sources. `imagePackage = null` selects OTA images.

## Rootless

Enable `virtualisation.miodroid-rootless.enable` on the host and
`programs.miodroid-rootless.enable` in Home Manager. Add the account to the
configured Miodroid group and `lxc-user`, and allocate subordinate UID/GID ranges
(at least 131072 IDs each for the primary Android user, including isolated
processes). The usual automatic 65536-ID allocation is too small. The kernel needs Binderfs, user namespaces, and FUSE. NixOS
prepares the LXC network bridge and the normal LXC/FUSE mapping helpers; the
container manager itself runs as the desktop user, with cgroup delegation.

A small static bootstrap mounts Binderfs inside LXC's own user/mount namespace
and explicitly allocates missing Binder devices before executing Android init.
The manager and desktop services access those same devices through the running
container's process root. No host device nodes or sibling mount namespaces are
needed, and stopping LXC releases the mount. `hostBinderfs` is retained only for
external tools requiring legacy host nodes. Restart refreshes all desktop Binder
services against the new container's devices.

Desktop sockets are forwarded through private per-session proxies. The proxies
preserve SCM_RIGHTS file descriptors needed for Wayland buffers and PulseAudio
shared memory. Original socket and runtime-directory permissions are unchanged.
Android kernel logging uses `/dev/null`, not a writable host `/dev/kmsg`.

Read-only images with writable FUSE overlays are the default. The `grow`
strategy remains available for compatibility; it checks and enlarges private
image copies. Both host and Home Manager image strategies must match. Converted
image cache keys include source size and modification time to invalidate OTA
images replaced at the same path.

Container root maps to the desktop UID/GID, other IDs use the account's actual
subordinate ranges, and the last subordinate ID is reserved for Android's
`INT_MAX` UID/GID. Missing or undersized ranges fail instead of silently using
another account's IDs. Larger ranges are needed for additional Android users:
Android user N uses app IDs starting at `N * 100000`. Allocate nonoverlapping
ranges large enough for the users you intend to run. For example, with an
otherwise unused range:

```nix
users.users.alice = {
  extraGroups = [ "miodroid" "lxc-user" ];
  subUidRanges = [{ startUid = 100000; count = 2097152; }];
  subGidRanges = [{ startGid = 100000; count = 2097152; }];
};
```

Rootful Binder device names and mounts are also Miodroid-specific. Named
bridges use short hashed names, container MAC addresses derive from the work
directory, and rootful subnets use 172.29.x.0/24 with the gateway outside the DHCP
pool. A conflicting selected subnet fails explicitly instead of sharing another
instance's network. Desktop entries preserve each instance's environment and
use separate filenames.

Named instances use `miodroid -I NAME`; names contain letters, digits, and
underscores. Rootless default state is `$XDG_DATA_HOME/miodroid.NAME` (or
`~/.local/share/miodroid.NAME`). `MIODROID_WORK` overrides the whole instance
state directory. Every instance must have its own directory. Host rootful and
rootless NixOS modes are mutually exclusive; upstream Waydroid remains separately
named.

## Automated checks

```
nix build .#miodroid
nix build .#checks.x86_64-linux.miodroid-desktop-sockets
nix build .#checks.x86_64-linux.miodroid-nixos
nix build .#checks.x86_64-linux.miodroid-nixos-rootless
nix build .#checks.x86_64-linux.miodroid-nixos-rootless-grow
```

The VM checks use the pinned image bundle, a real headless Weston compositor,
and a real PulseAudio server. They require KVM. Both modes assert Android boot,
Binder-backed app listing and launch, graphics/audio services, desktop
notification delivery, unchanged socket permissions, Android networking,
persistent state, restart, and stop. The rootful check also covers
freeze/unfreeze; unprivileged LXC cannot write `cgroup.freeze` in the delegated
user cgroup. The socket check independently exercises bidirectional data, file
descriptor passing, disconnection, and permission preservation.

Headless software rendering does not validate physical GPU/camera hardware,
NVIDIA extensions, ARM translation, GApps, or every community Android image.
