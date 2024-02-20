{ pkgs, sane-lib, ... }:

{
  nix.extraOptions = ''
    # see: `man nix.conf`
    # useful when a remote builder has a faster internet connection than me
    builders-use-substitutes = true  # default: false
    # maximum seconds to wait when connecting to binary substituter
    connect-timeout = 3  # default: 0
    # download-attempts = 5  # default: 5
    # allow `nix flake ...` command
    experimental-features = nix-command flakes
    # whether to build from source when binary substitution fails
    fallback = true  # default: false
    # whether to keep building dependencies if any other one fails
    keep-going = true  # default: false
    # whether to keep build-only dependencies of GC roots (e.g. C compiler) when doing GC
    keep-outputs = true  # default: false
    # how many lines to show from failed build
    log-lines = 30  # default: 10
    # how many substitution downloads to perform in parallel.
    # i wonder if parallelism is causing moby's substitutions to fail?
    max-substitution-jobs = 6  # default: 16
    # narinfo-cache-negative-ttl = 3600  # default: 3600
    # whether to use ~/.local/state/nix/profile instead of ~/.nix-profile, etc
    use-xdg-base-directories = true  # default: false
    # whether to warn if repository has uncommited changes
    warn-dirty = false  # default: true
  '';

  # hardlinks identical files in the nix store to save 25-35% disk space.
  # unclear _when_ this occurs. it's not a service.
  # does the daemon continually scan the nix store?
  # does the builder use some content-addressed db to efficiently dedupe?
  nix.settings.auto-optimise-store = true;

  # allow `nix-shell` (and probably nix-index?) to locate our patched and custom packages
  nix.nixPath = [
    "nixpkgs=${pkgs.path}"
    # note the import starts at repo root: this allows `./overlay/default.nix` to access the stuff at the root
    # "nixpkgs-overlays=${../../..}/hosts/common/nix-path/overlay"
    # as long as my system itself doesn't rely on NIXPKGS at runtime, we can point the overlays to git
    # to avoid switching so much during development
    "nixpkgs-overlays=/home/colin/dev/nixos/hosts/common/nix/overlay"
  ];

  # ensure new deployments have a source of this repo with which they can bootstrap.
  environment.etc."nixos".source = ../../..;

  systemd.services.nix-daemon.serviceConfig = {
    # the nix-daemon manages nix builders
    # kill nix-daemon subprocesses when systemd-oomd detects an out-of-memory condition
    # see:
    # - nixos PR that enabled systemd-oomd: <https://github.com/NixOS/nixpkgs/pull/169613>
    # - systemd's docs on these properties: <https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#ManagedOOMSwap=auto%7Ckill>
    #
    # systemd's docs warn that without swap, systemd-oomd might not be able to react quick enough to save the system.
    # see `man oomd.conf` for further tunables that may help.
    #
    # alternatively, apply this more broadly with `systemd.oomd.enableSystemSlice = true` or `enableRootSlice`
    # TODO: also apply this to the guest user's slice (user-1100.slice)
    # TODO: also apply this to distccd
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMSwap = "kill";
  };
}
