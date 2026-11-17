# ARTEX upstream image through Nix

`pkgs/by-name/artex-image.nix` uses the existing
[containerfile-nix](https://github.com/imincik/containerfile-nix)
`buildContainerFile` function. Both the helper and the ARTEX source are pinned by
Git revision and source hash. The helper runs Podman in a temporary Linux VM,
builds the source repository's unmodified `Dockerfile.safe`, then saves the image
as `$out/artex.tar`.

The image keeps the Dockerfile's base images, apt/npm installation steps,
browser stack, entrypoint, command, and health check. There is no separate
Nix packaging of ARTEX, its frontend, or its browser stack.

Build from the repository root:

```sh
nix build .#artex-image -L --option sandbox relaxed --builders ""
podman load -i result/artex.tar
```

New files must be tracked for Git flake evaluation. `git add --intent-to-add
pkgs/by-name/artex-image.nix docs/artex-image.md` makes the new files visible to
Git flakes without staging their contents.

The helper sets `__noChroot = true` and needs `sandbox = relaxed`, because image
pulls and the Dockerfile's `RUN` commands access the network. The Nix daemon must
permit that setting. A Linux builder with KVM support is required. By default,
the build VM has 4 GiB RAM and a 20 GiB sparse storage disk; these can be changed
with the package's `vmMemorySize` and `vmDiskSize` arguments. For ARTEX, plan for
at least 25 GiB of real free disk space for base images, intermediate storage,
and the exported archive.
If `/tmp` is a small tmpfs, select a disk-backed Nix build directory. Podman's
image-transfer temporary files are directed to `/var/lib/containerfile-tmp` on
the VM's storage disk, rather than its small `/tmp` tmpfs. The VM uses kernel
overlay storage and disables intermediate-layer caching to reduce disk usage.
The builder explicitly selects Docker image format so `HEALTHCHECK` is retained.

This is an ordinary Dockerfile build wrapped by Nix: fixing the source and base
image digests does not make unpinned apt repositories and image metadata
bit-for-bit reproducible. In particular, upstream declares `PLAYWRIGHT_*` build
arguments before the first `FROM` without redeclaring them in the runtime stage.
Those variables are out of scope for that stage's `RUN npm install`, so npm can
resolve current versions; the verified build installed Playwright 1.65.1 despite
the global argument's 1.65.0 value. This wrapper leaves that Dockerfile unchanged.
A normal build reuses the Nix store result; changing the source revision
invalidates it.

`mod/artex.nix` loads the archive with `imageFile` and keeps the existing realm
PostgreSQL connection and host networking. It also retains editable skills and
seeds them from the pinned source when their bind mount is empty. JWT keys use
the upstream `/app/keys` directory, mounted separately from the data workspace.
The Dockerfile's default proxy listens on `:8788`; host networking exposes that
listener on the host, subject to the host firewall.

When migrating, preserve the old container's `/app/jwt.key` as
`/var/lib/artex/keys/jwt.key` (root-owned, mode 0600) if existing login sessions
must remain valid. Otherwise a new key is generated.
