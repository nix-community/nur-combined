# nur-packages-silicalet

Personal [NUR](https://github.com/nix-community/NUR) packages.

All package sources are pinned by version/tag and hash, so evaluation remains
pure and reproducible.

## Update packages

Update selected packages:

```console
nix run .#update -- amber-lsp quien
```

Update every package that follows a standard upstream tag:

```console
nix run .#update -- --all
```

Running without a package only shows the usage and available package names:

```console
nix run .#update
```

Show the default update set without changing anything:

```console
nix run .#update -- --list
```

Binary packages update `x86_64-linux` by default. Select the ARM64 release
assets explicitly when needed:

```console
nix run .#update -- --arch aarch64-linux nyaterm-bin meatshell-bin
```

The updater is written in [Amber](./maintainers/update.ab). It invokes
`nix-update` with build validation and formatting for regular packages, while
packages with their own `update.ab` use that package-local updater. The binary
package updaters select the requested system's GitHub Release asset, version,
and hash. The default update set uses `meatshell-bin` and `nyaterm-bin` to avoid
rebuilding their slower source packages. Both select the matching release asset
for `x86_64-linux` or `aarch64-linux`; MeatShell uses its official ARM64 tarball
because upstream does not publish an ARM64 AppImage.
`cangjie` is built from the upstream source repositories, while the previous
vendor binary package remains available as `cangjie-bin`.

## Automatic updates

The `Update NUR packages` GitHub Actions workflow runs every Monday at 03:17
UTC (11:17 Asia/Shanghai) and can also be started manually. It updates the
default package set, validates native x86_64 builds, updates the aarch64 source
pins for binary packages, and commits successful changes directly to the
repository's default branch.

Projects with maintained binary packages use `meatshell-bin`, `neomacs-bin`,
and `nyaterm-bin`; their source-built counterparts are intentionally excluded
from automatic updates. The workflow uses the repository-provided
`GITHUB_TOKEN` and therefore requires GitHub Actions to have read/write
workflow permissions and permission to push to the default branch.
After pushing an update, it explicitly dispatches the regular package build
workflow because commits made with `GITHUB_TOKEN` do not trigger another
workflow from the ordinary `push` event.
