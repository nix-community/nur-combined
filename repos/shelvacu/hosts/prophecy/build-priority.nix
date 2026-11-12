# Keep large nix builds here from starving the guests. (This was written for
# jv-shel, a guest running an etcd member and half of a Postgres pair, whose WAL
# fsyncs took seconds under a build; it has since moved to its own hardware.)
{ ... }:
let
  mib = 1024 * 1024;
in
{
  # Nice=10 on nix-daemon (common/nixos.nix) only ranks it against its siblings
  # inside system.slice. Across the top of the cgroup tree, system.slice and
  # vacuvm.slice get equal CPU weight, so a build competes with the VMs as
  # though it were not niced at all. Hang the daemon (and so every build it
  # spawns) off its own top-level slice and make that slice SCHED_IDLE relative
  # to its siblings: builds then only get CPU nothing else wants.
  systemd.slices.nix-builds = {
    description = "nix-daemon and its builds";
    sliceConfig.CPUWeight = "idle";
  };
  systemd.services.nix-daemon.serviceConfig.Slice = "nix-builds.slice";

  # The kernel defaults (10% / 20% of RAM) let a build pile gigabytes of dirty
  # pages into the cache before anything is written. Everything shares one
  # btrfs, so each transaction commit then has to push all of it out, and
  # every fsync on the filesystem waits on that, the guests' included. With small
  # limits, writeback runs steadily and heavy writers are throttled when they
  # write, not later.
  boot.kernel.sysctl = {
    "vm.dirty_background_bytes" = 64 * mib;
    "vm.dirty_bytes" = 512 * mib;
  };
}
