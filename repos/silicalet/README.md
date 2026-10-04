# nur-packages-silicalet

Personal [NUR](https://github.com/nix-community/NUR) packages.

All package sources are pinned by version/tag or commit and hash, so evaluation remains
pure and reproducible.

Package expressions live under `pkgs/apps`, `pkgs/tools`, and `pkgs/lang`.
Those directories are only for organization: exported attribute names, update
commands, and NUR consumers stay flat.

## Quark Drive CLIs

Run either client:

```console
nix run .#quarkpan -- --help
nix run .#kuake-cli -- --help
```

`quarkpan` builds [quarkpan-rs](https://github.com/niuhuan/quarkpan-rs)
from a pinned commit; its updater follows the default branch because upstream
has no release tags. `kuake-cli` builds tagged releases of
[kuake_cli](https://github.com/zhangjingwei/kuake_cli) and installs the `kuake`
command. Both clients require your own Quark cookies for cloud operations.
Both packages are included in the default update set.

## ModelTrace

Run the local model-attribution web application:

```console
nix run .#modeltrace
```

The application opens `http://127.0.0.1:7860/` and listens only on loopback.
Writable fingerprint banks are stored in `$XDG_DATA_HOME/modeltrace`, falling
back to `$HOME/.local/share/modeltrace`. Bundled data seeds missing files;
existing banks and custom data are not overwritten on restart or upgrade.
ModelTrace has no upstream release tags, so its updater follows the default
branch and pins the resulting commit and source hash.

## Update packages

Update selected packages:

```console
nix run .#update -- amber-lsp quien
```

Update every package in the default update set:

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
and hash. The default update set uses `meatshell-bin` to avoid rebuilding its
slower source package. `nyaterm` is binary-only and updates through `nyaterm-bin`.
Both select the matching release asset for `x86_64-linux` or `aarch64-linux`;
MeatShell uses its official ARM64 tarball because upstream does not publish an ARM64 AppImage.
`nyaterm-gpui-bin` tracks the `v2.0.0-preview` GPUI pre-release instead of the stable Tauri release.
Run it with `nix run .#nyaterm-gpui-bin`.

`cangjie` is built from the upstream source repositories, while the previous
vendor binary package remains available as `cangjie-bin`.

## Automatic updates

The `Update NUR packages` GitHub Actions workflow runs daily at 03:17
UTC (11:17 Asia/Shanghai) and can also be started manually. It updates the
default package set, validates native x86_64 builds, updates the aarch64 source
pins for binary packages, and commits successful changes directly to the
repository's default branch.

Projects with maintained binary packages use `meatshell-bin`, `neomacs-bin`,
and `nyaterm-bin`. MeatShell's source package is excluded from automatic updates;
NyaTerm is exported only as `nyaterm-bin`. The workflow uses the repository-provided
`GITHUB_TOKEN` and therefore requires GitHub Actions to have read/write
workflow permissions and permission to push to the default branch.
After pushing an update, it explicitly dispatches the regular package build
workflow because commits made with `GITHUB_TOKEN` do not trigger another
workflow from the ordinary `push` event.

## Folia

`folia-major-bin` packages the official Linux x86_64 release, including Electron,
FFmpeg, and the Wayland wallpaper helper. Upstream does not publish Linux ARM64
binaries. Run it with `nix run .#folia-major-bin`; update its pinned release with
`nix run .#update -- folia-major-bin`. It is included in the default update set.

Wallpaper mode requires a compositor supporting `wlr-layer-shell`. If graphics
render incorrectly, try `FOLIA_LINUX_GRAPHICS_MODE=swiftshader` or `software`.
Optional analysis models are downloaded by Folia into its user data directory.
