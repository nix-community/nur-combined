# nur-packages-silicalet

Personal [NUR](https://github.com/nix-community/NUR) packages.

All package sources are pinned by version/tag or commit and hash, so evaluation remains
pure and reproducible.

Package expressions live under `pkgs/apps`, `pkgs/tools`, and `pkgs/lang`.
Those directories are only for organization: exported attribute names, update
commands, and NUR consumers stay flat.

## REA

`rea` packages [REA](https://github.com/morluto/rea), a reverse engineering CLI
and MCP server. Nix supplies Node.js and Linux process utilities; no global npm
installation is needed.

```console
nix run .#rea -- --help
nix run .#rea -- setup --client codex --dry-run
nix run .#update -- rea
```

The package follows official `rea-agents-*` releases and is included in daily
updates. Each build checks the CLI version/help and an actual MCP stdio
initialization and tool listing. CI builds it on native x86_64 and ARM64 Linux.
Frida's matching native binding is included by default, pinned by version and
hash for both architectures. The updater follows REA's locked Frida version,
and the build checks local device access and process enumeration.
Ghidra, JADX, browsers, and other analysis providers
must be configured separately for the workflows that use them.

`rea-full` combines REA and the extra tools listed below into one installable
package. Installing it in a profile, `environment.systemPackages`, or
`home.packages` exposes both REA and the tools' commands on your terminal PATH:

```console
nix profile add .#rea-full
nix run .#rea-full -- --help
nix shell .#rea-full -c jadx --version
```

It includes the same dependency list and has the same provider configuration
and version limitations described below; it does not register MCP or configure
external providers automatically.

Extra analysis tools are exported as package lists. Add them to NixOS's
`environment.systemPackages` or Home Manager's `home.packages` to make their
commands available in your terminal as well as to REA:

```nix
let
  reaDependencies = inputs.nur-packages-silicalet.lib.reaDependencies pkgs;
in {
  environment.systemPackages = [
    inputs.nur-packages-silicalet.packages.${pkgs.stdenv.hostPlatform.system}.rea
  ] ++ reaDependencies.all;
  # Or select groups: reaDependencies.android ++ reaDependencies.packets
}
```

The groups are `native` (Ghidra), `android` (JADX, JDK, adb), `browser`
(Chromium), `packets` (Wireshark CLI and util-linux), `firmware` (binwalk,
unblob and util-linux), and `captures` (mitmproxy). `all` combines these lists
without duplicates. The function uses your supplied `pkgs`, so the tools follow
your configuration's nixpkgs. With a traditional NUR import, use
`nur.repos.silicalet.lib.reaDependencies.all` instead.

This is a convenience list, not a guarantee that every REA provider is ready.
In this repository's pinned nixpkgs, WABT is 1.0.41 rather than REA's required
1.0.42, and sigrok-cli does not match REA's required 0.7.2; both are excluded.
Commercial engines, specialized Python tools and format-specific firmware
extractors are not included. Providers still need their upstream configuration;
in particular, set the applicable `REA_*_PRLIMIT_COMMAND` to
`${pkgs.util-linux}/bin/prlimit` on NixOS instead of `/usr/bin/prlimit`.
Installing the lists does not set these environment variables or register MCP.

Manage upgrades through Nix rather than `rea update`. Updating this repository
does not upgrade your installed profile or Home Manager generation: update your
flake input and rebuild, or upgrade the profile containing REA.

For a declarative MCP configuration, set the command to `"${rea}/bin/rea"`
(where `rea` is this repository's package in your Nix configuration) and arguments
to `[ "mcp" ]`. Rebuilding then updates the command along with the package.
Alternatively, use the absolute path to `rea` in a persistent Nix profile.
Upstream `rea setup` records specific runtime and script paths; registrations
created that way must be refreshed after a Nix upgrade to avoid starting an old
store path. Use a persistent installation before applying setup; `nix run` alone
does not keep the package rooted against garbage collection.

## Nodecode

`nodecode-bin` packages the official Linux x86_64 release of
[Nodecode](https://github.com/nodecode-ai/nodecode), a coding agent running in
Common Lisp. The executable includes SBCL; no separate Lisp installation is
needed. Nix supplies OpenSSL, SQLite, Bash, Git and CA certificates, and keeps
the shipped source, cells and compiled cells beside the executable.

```console
nix run .#nodecode-bin -- --help
nix run .#nodecode-bin
nix profile add .#nodecode-bin
nix run .#update -- nodecode-bin
```

First launch opens upstream setup; configure your own model provider and
credentials. State stays in `~/.nodecode/` (or `NODECODE_HOME`). Upstream does
not publish an ARM64 Linux binary. The x86_64 package is included in CI and
daily tool updates; release versions, archive URLs and hashes are pinned.
The build checks CLI startup, Lisp evaluation, SQLite and OpenSSL hashing.

Manage installed versions through Nix, not `nodecode update`. The package does
not use upstream's `current`-link layout, so automatic self-updates default to
off; the upstream installer is not included. Keep `update.mode` set to `off`
if reusing an existing configuration that enabled it. Updating this checkout
does not upgrade your installed profile or NixOS/Home Manager generation.

Upstream may enable its background gateway automatically on first launch in
your account's home. Install persistently before using it. After a Nix upgrade,
run `nodecode gateway restart` from the new package: the generated user service
records the executable's store path. Alternatively, manage the gateway
declaratively with `ExecStart = "${nodecode-bin}/bin/nodecode serve"` in your
own service configuration.

Nodecode's agent code runs with your account's permissions; it is not sandboxed
by default. Optional cells, MCP servers and sandbox mode may require additional
programs on your PATH.

## NEU CLI

`neu-cli` builds [neu-cli](https://github.com/silicalet/neu-cli) from source and
installs the `neu` command for Northeastern University campus services:

```console
nix run .#neu-cli -- --help
nix run .#neu-cli -- webvpn ipgw.neu.edu.cn
```

The package runs the upstream Haskell tests during the build and includes
`xdg-open` for `webvpn --open`.
It uses unmodified upstream source with a package-local `http-types 0.12.6`
dependency, matching the upstream Cabal build.
Commands that access campus services require the
appropriate network access and, where applicable, your own account.
Upstream has no release tags, so the package pins a commit and its updater
follows the default branch. It is included in the default update set;
update it with `nix run .#update -- neu-cli`.

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

`kuake-cli` carries a path-guard patch that checks every symbolic-link hop.
This keeps system and credential paths protected even when `/etc` files point
into `/nix/store`, as in the CI container. All upstream Go tests remain enabled,
with additional symlink-chain regressions; the x86_64 package is also built by
the pull-request build workflow.

## Qrypt

`qrypt-bin` packages the official Linux x86_64 and ARM64 releases of
[qrypt](https://github.com/yinzhenyu-su/qrypt), a cloud drive CLI and FUSE
filesystem with optional rclone-compatible content and filename encryption.

```console
nix run .#qrypt-bin -- --help
nix run .#qrypt-bin -- fs list --config ./qrypt.toml /
nix run .#qrypt-bin -- mount --config ./qrypt.toml
```

Configure your own backends and credentials in `qrypt.toml` following the
upstream documentation. One-shot `fs` operations do not need a FUSE mount.
Mounting requires the host's `/dev/fuse` and a working FUSE setup. The package
provides `fusermount3` and prefers NixOS's privileged helpers in
`/run/wrappers/bin`. Upstream's explicit unmount helper uses conventional
`/bin` or `/usr/bin` paths; on NixOS, use `fusermount3 -u <mount-point>` if
automatic unmount fails.

The build checks an encrypted local-backend upload/download round trip.
Both architectures are included in CI and automatic updates. Update with
`nix run .#update -- qrypt-bin` (or add `--arch aarch64-linux`). Manage installed
versions through Nix rather than the upstream `upgrade`/`uninstall` commands.

## ArtCraft creative suite

`craft-suite-bin` installs all thirteen Craft applications and ArtCraft Launcher
from official Linux releases, including their headless CLIs, desktop entries,
icons, and licenses. Both `x86_64-linux` and `aarch64-linux` are supported.

```console
nix build .#craft-suite-bin
nix run .#photocraft-bin
nix shell .#photocraft-bin -c photocraft-cli --help
```

For a permanent installation, add `craft-suite-bin` to your NixOS or Home Manager
package list. Each application is also available separately: `photocraft-bin`,
`vectorcraft-bin`, `filmcraft-bin`, `lightcraft-bin`, `pdfcraft-bin`,
`effectcraft-bin`, `designcraft-bin`, `figcraft-bin`, `wordcraft-bin`,
`soundcraft-bin`, `deckcraft-bin`, `cadcraft-bin`, `gridcraft-bin`, and
`artcraft-launcher-bin`. The suite itself has no single default executable.

Manage these installations and updates through Nix. The launcher's own
installer and self-updater do not manage the read-only Nix store; applications
downloaded by the launcher are separate installations and may need additional
NixOS runtime support. The separate ArtCraft AI studio has no official Linux
binary and is not included. These applications are still early releases;
packaging does not imply that every editing feature is complete.

Update all Craft packages, or one application:

```console
nix run .#update -- craft-suite-bin
nix run .#update -- photocraft-bin
nix run .#update -- --arch aarch64-linux craft-suite-bin
```

The suite is included in the default daily update set. The updater pins each
application's version, download URL, and SHA-256 independently for each
architecture. CI builds the full suite on native x86_64 and ARM64 runners;
each application's build also checks its bundled CLI's `--help` command.

## Honk

`honk-bin` packages the official static musl release; `honk` builds `honk-core`
and its embedded eBPF object from source. Both target `x86_64-linux` and
`aarch64-linux`. The default `full` build includes Clash API, Native API and
both editions of Doona. Setting `withDoona = false` via `package.override`
selects the upstream `native-api` feature set: no embedded UI **and no Clash API**.

```nix
{ inputs, pkgs, ... }:
{
  imports = [ inputs.nur-packages-silicalet.nixosModules.honk ];
  services.honk-proxy = {
    enable = true;
    configDir = "/etc/honk"; # entry: /etc/honk/config.dae
    # Alternatively, set only configFile = "/run/secrets/honk.dae";
    # package = inputs.nur-packages-silicalet.packages.${pkgs.stdenv.hostPlatform.system}.honk;
    doona = true;
  };
}
```

Use exactly one absolute runtime path string. `configFile` may be a symlink;
Honk resolves `include { config.d/*.dae }` against the **resolved entry's parent**.
The module does not read credentials at evaluation time or copy them into the
store. The entry, include tree, symlinks and their parents must be controlled
by the administrator: `honk-core.service` reads them as root.

`doona` selects the package variant, not a listener. To serve the UI, explicitly
enable `experimental.native_api` in the Honk config with authentication, bind
to loopback and choose `ui: 'embedded'` or `'embedded-lite'`. The module opens
no firewall ports by default. It supplies nixpkgs' `v2ray-geoip` and
`v2ray-domain-list-community` through `DAE_LOCATION_ASSET`; override `assets`
or `assetsPath` for a different dataset.

For a CLI-only installation, import `homeModules.honk` in Home Manager and set
`programs.honk.enable = true`. It does not start a user service. Real interception
requires Linux 6.12+, cgroup v2 and mounted bpffs; keep a recovery path for the
first start. Hot-reloadable config changes use `systemctl reload honk-core`;
native API or interface changes require a restart.

`honk-bin` full and native-api release hashes update together per architecture.
The source package is updated manually so the Honk tag, Rust toolchains, Cargo
Git dependencies, BPF linker and Doona assets can be checked together.

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

The updater is [maintainers/update.py](./maintainers/update.py). It edits the
checkout in the current working directory; set `NUR_PACKAGES_ROOT` to point it
at a different checkout. Regular
packages go through `nix-update` with build validation and formatting. Binary
packages select the requested system's GitHub Release asset, version, and
hash. A failure in one package is reported and the remaining packages still
update; the command exits nonzero after the full set if any package failed.
The default update set uses `meatshell-bin` to avoid rebuilding its
slower source package. `nyaterm` is binary-only and updates through `nyaterm-bin`.
Both select the matching release asset for `x86_64-linux` or `aarch64-linux`;
MeatShell uses its official ARM64 tarball because upstream does not publish an ARM64 AppImage.
`nyaterm-bin` tracks the stable release, which is now the GPUI build.

`cangjie` is built from the upstream source repositories, while the previous
vendor binary package remains available as `cangjie-bin`.

## Automatic updates

Package updates run in independent category workflows, daily at 03:17 UTC
(11:17 Asia/Shanghai), or manually from the Actions page:

| Workflow | Category | ARM64 binary updates |
| --- | --- | --- |
| `update-apps.yml` | `pkgs/apps` | craft-suite, meatshell, neomacs, nyaterm |
| `update-tools.yml` | `pkgs/tools` | honk-bin, qrypt |
| `update-ctf.yml` | `pkgs/ctf` (REA) | Frida bindings for both architectures are handled by the REA updater |

These workflows call `update-packages.yml`, which is reusable rather than a
standalone scheduled workflow. Each category validates its native x86_64 builds
and configured ARM64 pins before committing only its own package directory.
A failed category publishes nothing but does not block the other categories;
in particular, a REA failure cannot prevent apps/tools updates. Failures within
the same category still block that category's commit.

Only the tools workflow updates and commits `flake.lock`. Categories have
separate concurrency groups. Concurrent pushes fetch and rebase onto the default
branch, retrying a rejected push up to five attempts; merge conflicts stop the
job instead of overwriting changes. `rea` and `rea-full` keep their public Nix
attribute names, with definitions under `pkgs/ctf/rea`.
`lang/cangjie` remains manually maintained, as it was not in the automatic update set.

Projects with maintained binary packages use `meatshell-bin`, `neomacs-bin`,
and `nyaterm-bin`. MeatShell's source package is excluded from automatic updates;
NyaTerm is exported only as `nyaterm-bin`. The workflows use the repository-provided
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
