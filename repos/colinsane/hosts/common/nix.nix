{ config, lib, pkgs, ... }:

{
  nix.checkConfig = false;  #< don't error the build if we specify unknown settings; nix/lix handles those gracefully at runtime.
  nix.settings = {
    # see: `man nix.conf`

    # useful when a remote builder has a faster internet connection than me.
    # note that this also applies to `nix copy --to`, though.
    # i think any time a remote machine wants a path, this means we ask them to try getting it themselves before we supply it.
    builders-use-substitutes = true;  # default: false

    # maximum seconds to wait when connecting to binary substituter
    connect-timeout = 3;  # default: 0

    download-attempts = 2;  # default: 5

    # allow `nix flake ...` command
    experimental-features = [ "nix-command" "flakes "];

    # whether to build from source when binary substitution fails
    fallback = true;  # default: false

    # give me `nix-build` style output in the repl, please (lix 2.95+)
    # log-format: `raw-with-logs` = nix-build default style.
    # log-format: `bar` = `nix repl` default style.
    # log-format: `multiline-with-logs` is like `bar-with-logs`, but splits the status across multiple lines (`[A/B/C built]` / `Building ${pname} ${phase}`)
    log-format = "bar-with-logs";

    # whether to keep building dependencies if any other one fails
    keep-going = true;  # default: false

    # whether to keep build-only dependencies of GC roots (e.g. C compiler) when doing GC
    keep-outputs = true;  # default: false

    # how many lines to show from failed build
    log-lines = 30;  # default: 10

    # max-connect-timeout = 20;  # default 300; in seconds.

    # how many substitution downloads to perform in parallel.
    # i wonder if parallelism is causing moby's substitutions to fail?
    max-substitution-jobs = 6;  # default: 16

    trusted-users = [
      # fix "user is not a trusted user" when using `--substituters`
      "@wheel"
    ];

    # narinfo-cache-negative-ttl = 3600  # default: 3600
    # whether to use ~/.local/state/nix/profile instead of ~/.nix-profile, etc
    use-xdg-base-directories = true;  # default: false

    # whether to warn if repository has uncommited changes
    warn-dirty = false;  # default: true

    # hardlinks identical files in the nix store to save 25-35% disk space.
    # - in practice, that's 700GB saved (allegedly) on a 2150GB (allegedly) nix store (living on a 8TB SSD)
    #   as reported by `nix path-info --json --all | jq 'map(.narSize) | add'`
    # manually optimize by invoking: `nix-store --optimise`.
    # view space savings by invoking: `nix-store --gc --max-freed 1 | grep "currently hard linking saves"`
    #
    # unclear _when_ this occurs. it's not a service.
    # does the daemon continually scan the nix store?
    # does the builder use some content-addressed db to efficiently dedupe?
    #
    # N.B.: hardlinks are an impurity; see e.g.: <https://github.com/NixOS/infra/issues/438>
    # `tar` preserves hardlinks found in the store by default, which is almost *never* what you want.
    #
    # auto-optimise-store = true;  # default: false

    # allow #!nix-shell scripts to locate my patched nixpkgs & custom packages.
    # this line might become unnecessary: see <https://github.com/NixOS/nixpkgs/pull/273170>
    # nix-path = config.nix.nixPath;
  };

  # ensure new deployments have a source of this repo with which they can bootstrap.
  # this however changes on every commit and can be slow to copy for e.g. `moby`.
  environment.etc."nixos" = lib.mkIf (config.sane.maxBuildCost >= 3) {
    source = pkgs.sane-nix-files;
  };
  environment.etc."nix/registry.json" = lib.mkIf (config.sane.maxBuildCost < 3) {
    enable = false;
  };

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
