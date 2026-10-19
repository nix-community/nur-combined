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
module and kernel configuration, then builds this single kernel on nixbuild.net.
The required `test-gate` waits for both ordinary package tests and the kernel
workflow, including publication on main.

### All CI builds run on nixbuild.net

Every workflow that builds with Nix (`build.yml` packages, `kernel.yml`,
`update.yml`'s nix-update fetcher builds) uses the shared
`.github/actions/setup-nix-nixbuild` action. It installs Nix, configures
`uriotv.cachix.org` read-only and enables `nixbuild/nixbuild-action`, which sets
`max-jobs = 0`: nothing is compiled on the GitHub runner. The action fails when
`NIXBUILD_TOKEN` is missing and verifies the configuration; there is no silent
fallback to a GitHub runner build. `update-kernel.yml` only downloads sources
(`nix store prefetch-file`), so it needs no builder.

The kernel job sets `min-cpu = 16`, because nixbuild.net assigns 2 CPUs to builds
without historic data. The actual allocation is bounded by nixbuild.net's limits.
Results stay in your nixbuild.net store, so an identical derivation (e.g. the PR
build followed by the main build) is served back instead of compiled and billed
again. Outputs are copied back to the runner and then explicitly pushed to Cachix.

Setup: create a token in the nixbuild.net shell and store it as the repository
Actions secret `NIXBUILD_TOKEN` (Settings → Secrets and variables → Actions). Also
add it as a Dependabot secret if Dependabot PRs should pass CI; Dependabot runs
do not receive Actions secrets.

```console
ssh eu.nixbuild.net shell
# In the nixbuild.net shell:
tokens create -p build:read -p build:write -p store:read -p store:write
```

Keep the token private. Pull-request runs receive it as well: PR creation is
restricted to repository collaborators, and fork PRs never get Actions secrets
(they fail at the token check). Limit charges with the account-level
`max-cpu-hours-per-month` setting in the nixbuild.net shell (default 2000).

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

Kernel job logs contain elapsed time, output sizes and free disk space; the
nixbuild.net job summary lists CPU usage. The job stops after 240 minutes to
bound a stuck remote build. The free Cachix
plan has a shared 5 GB storage allowance and LRU eviction. Uploads of complete
sources consume space too. The runner still needs disk space for the copied-back
outputs before they are pushed. A failed build/publication
blocks the gate instead of being reported as success. Do not enable an untested
kernel automatically on your workstation.

## Optional local build and publication (powerful desktop)

From this repository, use the flake app:

```console
# Compile all outputs and sources, without any credentials or upload:
nix run .#build-and-cache-kernel -- --build-only

# Compile and publish; automatically find the decrypted sops-nix token:
nix run .#build-and-cache-kernel

# Limit parallelism if RAM is tight:
nix run .#build-and-cache-kernel -- --cores 8 --token-file /run/secrets/cachix_auth_token
```

The command looks for a readable, nonempty secret in `/run/secrets`, then
`$XDG_RUNTIME_DIR/secrets` (Home Manager), then
`${XDG_CONFIG_HOME:-$HOME/.config}/sops-nix/secrets`. Within each directory, names
are tried in order: `cachix_auth_token`, `uriotv_cachix_auth_token`, `cachix_token`,
`CACHIX_AUTH_TOKEN`, `cachix/auth_token`, `cachix`. Only these named files are read;
it never searches or decrypts unrelated secrets. A custom secret directory can
be supplied via `CACHIX_SOPS_SECRETS_DIR`.

This repo includes a pinned sops-nix input, recipient/token templates and the
optional `nixosModules.kernel-publisher` module to provision that runtime file.
See [local SOPS setup](../../secrets/README.md) for the full workflow. You must
supply actual public recipients and a token in the SOPS editor, then import and
activate the module on the desktop yourself. If the host already uses sops-nix,
use `nixosModules.kernel-publisher-options` instead to avoid duplicate imports.
The secret is owned by your configured user, mode `0400`.
There is no automatic access to the value of GitHub Actions Secrets.

Explicit `--token-file` / `CACHIX_AUTH_TOKEN_FILE` overrides take precedence, then
an existing `CACHIX_AUTH_TOKEN`, then automatic sops-nix discovery. An unreadable
explicit path is an error, never a reason to silently use a different token.
Never put the token itself in command arguments or Nix expressions. Credentials
are checked before compilation and removed from the `nix build` environment;
only the Cachix upload needs them. The app does not configure sops-nix or mutate
any system configuration.

Without cloning, use a specific repository commit (after it has been published):

```console
nix run github:urioTV/urio-nur/<commit>#build-and-cache-kernel -- --build-only
```

The app builds the source revision it came from, not the caller's working
directory or a moving branch. It uses `nproc` cores by default and one Nix build
job. `--cores` changes parallelism only: no `-march=native` or local CPU tuning
is introduced, so the kernel derivation is identical to CI for the same pin.
All outputs and source artifacts are pushed and their remote narinfo verified.
No kernel is installed or activated. Normal Nix sandboxing must stay enabled.

To let CI substitute a locally uploaded build instead of recompiling it, build
exactly the source/compiler pin used by CI. A job already compiling may not
recheck the cache midway through its build. Uploading a different revision does
not satisfy the current job. Cache read access on the desktop follows your Nix
configuration (see the earlier bootstrap-cache instructions).

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
