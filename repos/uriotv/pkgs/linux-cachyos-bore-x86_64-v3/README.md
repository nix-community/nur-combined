# CachyOS BORE x86_64-v3

Only **latest stable CachyOS + BORE + x86_64-v3, without LTO** is built. No LTS,
v1/v2/v4/Zen4, ZFS, NVIDIA or other external modules are built by this pipeline.
`latest` here means the latest stable kernel in the pinned upstream definitions,
not a Linux release candidate. This is a source build, not an Arch kernel binary.

## Installation on NixOS (recommended: pinned flake module)

Add `urio-nur.url = "github:urioTV/urio-nur"` to your inputs and import
`urio-nur.nixosModules.cachyos` in your NixOS configuration. The default module
also exports these options. Merely importing the module does not enable it.

First enable the binary cache **without changing the running kernel**:

```nix
{
  imports = [ urio-nur.nixosModules.cachyos ];
  nix.settings = {
    substituters = [ "https://uriotv.cachix.org" ];
    trusted-public-keys = [ "uriotv.cachix.org-1:goitmxx1/DXbyeFNubk9Dmp9nvg4V188Wvu4CdrRsyI=" ];
  };
}
```

Activate this configuration yourself before enabling the kernel: the daemon's
cache configuration must already be active while it builds the next generation.
Check the kernel CI for your pinned commit: it must have completed publication,
not just PR compilation. Cache eviction can still cause local compilation.

Verify CPU compatibility on the actual computer. `x86_64-linux` alone does NOT
imply x86_64-v3. On a glibc system, for example:

```console
$(nix eval --impure --raw --expr '(import <nixpkgs> {}).glibc')/lib/ld-linux-x86-64.so.2 --help
```

The loader's hardware-capability list should mark `x86-64-v3` as supported.
Also check the CPU flags with `lscpu`; do not infer support just from AVX2 alone.
Then enable the kernel:

```nix
{
  boot.cachyos = {
    enable = true;
    cpuSupportsV3 = true; # explicit acknowledgement, NOT CPU detection
    # cache.enable = false; # only if you configure the cache separately
  };
}
```

On your machine run the usual `nh os switch .` from your NixOS configuration
repository, then reboot when convenient. Keep an older boot generation as a
fallback. Secure Boot signing, bootloader setup and proprietary module support
are not configured automatically. Test external modules against this kernel;
new kernels can temporarily be incompatible with NVIDIA, ZFS or VirtualBox.

### Why a separate nixpkgs pin?

`upstream/source.json` records the upstream Git revision/hash **and its own
matching nixpkgs revision/hash**. Flake kernel outputs and the NixOS module import
that exact compiler/package set via `pinned.nix`, independently of the consumer's
nixpkgs. Following `urio-nur.inputs.nixpkgs` to another input does not change the
kernel pin. Overriding kernel configuration/patches DOES change its store path
and can require local compilation.

Exports:

- `packages.x86_64-linux.linux-cachyos-bore-x86_64-v3`
- `legacyPackages.x86_64-linux.linuxPackages-cachyos-bore-x86_64-v3`
- `nixosModules.cachyos` (also imported by `nixosModules.default`)

`boot.cachyos.kernelPackages` allows an explicit package-set override. The
non-flake module (`modules.cachyos` in a direct NUR import) and the direct NUR
package use the caller's nixpkgs; they do not promise a cache hit. Prefer the
flake module above. No native-CPU compilation is used; the binary is shared
across CPUs supporting v3.

## CI, publication and updates

`build.yml` calls the reusable `kernel.yml` workflow on pull requests, main pushes,
the regular scheduled build and manual dispatch. It evaluates the real NixOS
module and kernel configuration, then builds this single kernel with four cores
and one Nix job. The required `test-gate` waits for both ordinary package tests
and the kernel workflow, including publication on main.

Publication occurs **only on main, never in pull-request jobs**. It requires the
existing repository secret `CACHIX_AUTH_TOKEN`. All kernel outputs (`out`, `dev`,
`modules`) are explicitly pushed, along with the patched kernel source and exact
GPL upstream build definitions. After upload CI checks every output's remote
`.narinfo` and `StorePath`. This is not a boot test or an independent cold-cache
restore test. Artifact storage in GitHub Actions is not used.

The ordinary channel-based `ci.nix` intentionally excludes this package so it
cannot silently compile a second copy with a different nixpkgs pin.

`update-kernel.yml` checks upstream daily at **04:23 UTC**, with manual dispatch
available. `update.py` snapshots the needed upstream files and matching nixpkgs
pin from a single immutable commit. It replaces the local snapshot only after
all downloads succeed, and opens an isolated `auto-update-cachyos-kernel` PR.
`PAT_FOR_UPDATES` is needed for bot PRs to trigger Actions; the repository already
has it. Auto-merge waits for the existing required `test-gate`. Without a PAT,
GitHub's default token may create a PR without triggering CI; merge stays blocked.

Manual update / validation:

```console
python3 pkgs/linux-cachyos-bore-x86_64-v3/update.py
./tests/run-tests.sh
nix eval --impure --json --file tests/cachyos-integration.nix
nix eval --impure --json --expr 'import ./tests/cachyos-module.nix {}'
nix build --no-link '.#packages.x86_64-linux.linux-cachyos-bore-x86_64-v3^*'
```

The first full GitHub build is a capacity pilot: logs contain elapsed time, peak
memory, output sizes and free disk space. Standard public GitHub runners are
free, but have a six-hour job cap; this job stops at 350 minutes. The free Cachix
plan has a shared 5 GB storage allowance and LRU eviction. Uploads of complete
sources consume space too. No guarantee is made that this kernel build fits the
time/disk/RAM limits before that first actual build. A failed build/publication
blocks the gate instead of being reported as success. Do not enable an untested
kernel automatically on your workstation.

## Source and licensing

`upstream/` contains unmodified files from
[xddxdd/nix-cachyos-kernel](https://github.com/xddxdd/nix-cachyos-kernel), under
**GPL-2.0** as provided in [`upstream/LICENSE`](upstream/LICENSE). That license is
not replaced by the top-level repository license. The wrapper selects only BORE
v3; the upstream snapshot includes definitions for other variants but they are
not exported or built here. Keep attribution/license when updating these files.

The exact upstream archive, compiler pin, kernel/config URLs and hashes are
recorded in `upstream/source.json` and `upstream/kernel-cachyos/version.json`.
The public repository retains historical pins and build instructions. CI also
publishes patched source and upstream definitions alongside the binary outputs
in Cachix, subject to cache retention. Preserve corresponding sources when
redistributing or archiving the binaries outside this pipeline.
