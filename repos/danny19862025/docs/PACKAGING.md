# Linux packages

The repository provides packaging recipes; native packages are not published in
a release yet. Build them locally on the target distribution, or run the optional
Linux Packages workflow. Do not assume a package built on one distribution is
compatible with another merely because both use .deb or .rpm.

| System | Package/build method | Recipe target |
| --- | --- | --- |
| Ubuntu, Kubuntu and compatible derivatives | .deb built on Ubuntu | Ubuntu 24.04 |
| Debian and compatible derivatives | .deb built on Debian | Debian 13 |
| Fedora | .rpm built on Fedora | Fedora 44 |
| openSUSE | .rpm built on openSUSE | Tumbleweed |
| Arch and derivatives | PKGBUILD / makepkg | Current Arch |
| NixOS and systems with Nix | Nix flake | See [NIX.md](NIX.md) |
| Void, Gentoo, Alpine and other systems | Native source build | See [INSTALL.md](INSTALL.md) |

GTK 4.10+ and a compatible Rust toolchain are required. Ubuntu 22.04 and Debian
12 have GTK versions too old for the stock source recipe. Derivatives need the
same libraries as their base release. openSUSE Leap is only eligible when its
enabled repositories supply GTK 4.10+; the automated target is Tumbleweed.

All formats install the core launcher, desktop entry, icon, extension catalog,
and required license notices. Optional Akonadi, free/busy and paste-queue helper
binaries are not bundled. See [PIM.md](PIM.md), [TOOLS.md](TOOLS.md) and the native
build scripts for those dependencies. KDE-specific features require KDE
services. Optional CLI tools are listed in the installation/feature guides.
These package recipes do not create login startup or modify keyboard shortcuts.
Use desktop settings to assign a shortcut to `spotlight`. The current
--install-shortcut implementation expects a user-local desktop entry, so it is
not suitable for these system packages. Autostart remains opt-in.

## Ubuntu and Debian

Install current stable Rust using the shared [source instructions](INSTALL.md),
then install the native build/packaging dependencies:

```sh
sudo apt update
sudo apt install build-essential git pkg-config libgtk-4-dev libsqlite3-dev dpkg-dev
```

From a checkout:

```sh
sh packaging/build-deb.sh
sudo apt install ./dist/spotlight_*.deb
```

Choose a single matching .deb if dist/ contains packages for multiple systems.
The script compiles locally and uses dpkg-shlibdeps to calculate library package
names and minimum versions from the actual linked binary. It creates a
native-architecture .deb with a distro/version suffix and root-owned archive
metadata; building does not need sudo. Inspect with `dpkg-deb --info FILE.deb`
and `dpkg-deb --contents FILE.deb`. Remove with `sudo apt remove spotlight`.

## Fedora

Install current stable Rust, then:

```sh
sudo dnf install gcc gcc-c++ git pkgconf-pkg-config gtk4-devel sqlite-devel rpm-build
sh packaging/build-rpm.sh
sudo dnf install ./dist/spotlight-*.rpm
```

Choose the package whose suffix matches your Fedora release. Remove with
`sudo dnf remove spotlight`.

## openSUSE Tumbleweed

Install current stable Rust, then:

```sh
sudo zypper install gcc gcc-c++ git pkgconf-pkg-config gtk4-devel sqlite3-devel rpm-build
sh packaging/build-rpm.sh
sudo zypper install ./dist/spotlight-*.rpm
```

Choose the openSUSE package matching your build environment. Remove with
`sudo zypper remove spotlight`.

The RPM script compiles on the native distribution, stages only the distributable
files, and passes that compiled payload to rpmbuild and packaging/rpm/spotlight.spec.
RPM automatically generates ELF shared-library dependencies. These are binary
RPMs; the payload archive is not a source RPM. Source is available in Git.
The script also checks for GTK 4.10+ via explicit package requirements. Inspect
packages with `rpm -qpi FILE.rpm` and `rpm -qpR FILE.rpm`. Locally built RPMs are
unsigned and are not official distribution packages.

## Arch Linux without AUR

```sh
sudo pacman -S --needed base-devel git
git clone https://github.com/danny19862025/spotlight.git
cd spotlight/packaging/arch
makepkg -si
```

Run makepkg as your normal user. The recipe pins the upstream v0.4.0 commit;
update pkgver and the full source commit together for future application releases.
Ordinary unit tests run in check(); desktop fixture tests stay opt-in. AUR
registration is not needed to use this recipe. Remove with `sudo pacman -R spotlight`.

## Tarballs and other distributions

On a compatible GNU/Linux build system:

```sh
cargo build --release --locked
sh packaging/package-release.sh
```

The archive includes a relocatable bin/spotlight launcher, lib/spotlight payload,
icon, desktop entry and licenses. Extract it and run `./bin/spotlight` from the
extracted directory. For desktop installation, use your distribution's package
recipe or follow the user-local installation instructions in INSTALL.md.

A tarball is dynamically linked, not an AppImage or a static executable. Its
minimum glibc/GTK/runtime versions come from its build environment. The optional
workflow creates it on Ubuntu 24.04; other systems need compatible libraries.
Do not run a glibc tarball on Alpine/musl or use it instead of the Nix package
on NixOS. Void/musl and Alpine should compile natively; Gentoo and other systems
can use the existing source instructions. No Flatpak, Snap or AppImage recipe
is included.

## Optional distribution workflow

The separately prepared .github/workflows/packages.yml workflow builds on
Ubuntu 24.04, Debian 13, Fedora 44 and openSUSE Tumbleweed. It installs each
result in its disposable build environment and checks for unresolved linked
libraries. It produces downloadable Actions artifacts on manual runs and draft
release assets on a v-prefixed tag matching Cargo.toml. Review and publish the
draft to make it public. Existing assets are not overwritten. x86_64 is the
hosted target; scripts also accept native ARM64 builds where supported.

The workflow is kept in a separate commit/branch so the recipes can be pushed
with a token that lacks GitHub's workflow permission. The workflow must be
installed separately with suitable authorization before it can run. Its checks
validate packaging and dynamic linking, not graphical behavior on each desktop.
The existing Rust CI covers application tests separately.

## Validation status

The shared staging layout, launcher, desktop entry, tarball and Arch package
have been checked on the available Arch host. Native Debian/Ubuntu and RPM
builds require their native tools and have not been run here. Nix also remains
unverified. Treat these new distro recipes as ready for testing, not as verified
cross-distribution releases.
