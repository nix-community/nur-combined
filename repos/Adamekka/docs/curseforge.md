# CurseForge for Linux

Packages the official standalone CurseForge desktop app for `x86_64-linux`.
The download comes from [Overwolf's official app page](https://www.overwolf.com/app/overwolf-curseforge).

From the repository root:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix run --impure .#curseforge
```

For NixOS or Home Manager, allow the unfree `curseforge` package and add this
repository's `curseforge` output to your package list. Installation provides the
`curseforge` command, desktop entry, icons, and the upstream `curseforge://`,
`cfauth://`, and `curseforge-checkout://` URL associations.

## Account login

Browser login returns to the app through a `cfauth://` link. The desktop session
finds this handler through a user application database that the launcher creates
automatically before starting CurseForge. This also works with `nix run`.

For a persistent installation, add the package through NixOS, Home Manager, or a
Nix profile. From the repository root, a profile installation is:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix profile add --impure .#curseforge
```

The launcher manages `applications/curseforge.desktop` and registration state
under `curseforge-nix/` in `${XDG_DATA_HOME:-$HOME/.local/share}`. It follows this
package's installed desktop entry in `XDG_DATA_DIRS` when available, retaining
the profile path so upgrades update the menu entry. Standalone runs register
their own package output. The profile link from the previous manual setup is
migrated automatically. A conflicting custom desktop entry is preserved and
reported with a diagnostic.

Registration is locked across concurrent launches and rebuilt on each launch.
The lock is released before starting the app so browser callbacks can launch
the same wrapper. The user MIME database keeps the handler discoverable even
when Electron repeats protocol registration during login. Ordinary MIME
preferences are left to the app and desktop session.

## Runtime

The launcher uses a per-app FHS environment for the bundled Electron app and
.NET agent, plus Java and game launchers downloaded after installation.
[CurseForge downloads Java automatically](https://support.curseforge.com/support/solutions/articles/9000218572).
No host-wide `nix-ld` setup is required. The host must permit unprivileged user
namespaces. The environment provides Linux compatibility and retains access to
your files and network.

The application, game installations, and downloaded runtimes keep their upstream
user data locations. Downloads performed by the app are not pinned by this
package. Game launches and account-dependent features require manual testing.

## Source and verification

`source.json` pins a versioned official Debian download and its SHA-256 hash.
The updater downloads the public Linux release, checks its package name,
architecture, and version, and records the corresponding versioned download URL.
The candidate build verifies that this URL serves exactly the bytes offered by
the public download. The in-app update feed can advertise a staged release ahead
of the public download, so it does not select the version for this package.

Run `python3 pkgs/curseforge/update.py` from the repository root with Python 3,
curl, and `dpkg-deb` available, or use the package's `passthru.updateScript`.
The updater rejects downgrades, unexpected package metadata, and archive changes
without a version bump. Such failures leave the current source pin untouched and
require manual review.

The build validates the installed desktop entry. The repository's generic CI
excludes unfree packages, so build this package explicitly before using an update:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#curseforge
```

## Daily updates and CI

`Update CurseForge` runs daily at 10:17 UTC and can also be started manually on
`main`. It prepares a candidate source pin, then calls `Test CurseForge` with the
exact candidate bytes and the `main` commit on which they were prepared. If the
public release has not changed, validation and publishing are skipped.

`Test CurseForge` runs the updater tests, checks Nix formatting, builds the
package for `x86_64-linux`, and validates its desktop entry. Outside the Nix build
sandbox, it launches the app under Xvfb with isolated user data directories and
requires the expected version, a visible GUI, and a connected, running .NET agent.
It also verifies automatic registration in clean user directories and checks
that all three URL handlers remain discoverable after repeated GIO registration.
Chromium's sandbox stays enabled. The disposable Ubuntu runner permits the user
namespaces needed by the FHS launcher. The same checks run on PRs, pushes to
`main`, and manual runs. Game launches and account-dependent features still need
manual testing. The proprietary application is not uploaded to the public cache.

Only after validation succeeds does a separate job with write permission commit
the tested `source.json` directly to `main`. It aborts if `main` changed during
validation; a non-force push also rejects a subsequent concurrent change. Start a
new updater run on `main` after this failure. Re-running an old job retains its
original base and cannot validate against the new one.

Both workflow files must be on `main` before daily updates can run. The repository
must allow `GITHUB_TOKEN` to push to `main`; these workflows do not change branch
protection. Token-authored pushes do not trigger another push workflow, so the
build and startup checks run before publishing.
