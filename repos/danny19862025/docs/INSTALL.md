# Installing Spotlight on Linux

See [Linux packages](PACKAGING.md) for native Debian/Ubuntu, Fedora/openSUSE, and Arch packaging recipes, or [Nix installation](NIX.md). To install directly from source, choose your distro below and follow the shared build steps. Native package releases are not published yet; no AppImage, Flatpak, or Snap is provided.

These instructions cover the main distro families and provide a general method for other distributions. The application has been checked on KDE Plasma with Wayland; the other distro recipes describe the required packages and have not all been tested on fresh installations.

## Requirements and desktop support

- A Linux graphical desktop with a working session D-Bus.
- **GTK 4.10 or newer**, including development headers. GTK 3 does not satisfy this requirement.
- SQLite3 development headers and linker library, used to read Klipper image history.
- A current stable Rust toolchain with Cargo, a C compiler/linker, and `pkg-config`.
- Git, curl, and CA certificates. Internet access is needed to download the source and Rust dependencies; currency conversion also uses curl at runtime.
- KDE Plasma is recommended for the full feature set.

The launcher, calculator, notes, snippets, and other local tools can be used on other GTK-compatible desktops, but those desktops are not fully verified. Clipboard history requires KDE Klipper; window actions require KWin; automatic shortcut registration requires KDE's shortcut service. Caffeinate uses KDE PowerDevil and the screen saver service. KDE Settings depends on KDE applications. Color picking needs a desktop portal backend with support for picking a color. Screen Measurement needs a working Screenshot portal. Installing build dependencies alone does not add these desktop services.

## 1. Install your distro's dependencies

Run only the subsection that matches your system. These commands install build tools, GTK, and SQLite3; they do not replace your desktop environment. Use your configured administrator account or `doas` instead of `sudo` where appropriate.

### Ubuntu, Kubuntu, Linux Mint, Pop!_OS, Zorin OS, KDE neon, and other Ubuntu derivatives

Use a release based on **Ubuntu 24.04 or newer** with GTK 4.10+. Check the base release of derivatives rather than their product version number. For example, Linux Mint 22 uses the Ubuntu 24.04 base.

```sh
sudo apt update
sudo apt install build-essential git curl ca-certificates pkg-config libgtk-4-dev libsqlite3-dev
```

Ubuntu 22.04's standard GTK packages are too old. Use a newer distro release rather than replacing the system GTK libraries manually. Ubuntu publishes the [GTK development package and version for 24.04](https://packages.ubuntu.com/noble/libgtk-4-dev).

### Debian and Debian derivatives

Use **Debian 13 (Trixie) or newer**, or a derivative whose repositories supply GTK 4.10+.

```sh
sudo apt update
sudo apt install build-essential git curl ca-certificates pkg-config libgtk-4-dev libsqlite3-dev
```

Debian 12's standard GTK 4.8 packages are too old. See Debian's package listings for [Trixie](https://packages.debian.org/trixie/libgtk-4-dev) and [Bookworm](https://packages.debian.org/bookworm/libgtk-4-dev).

### Arch Linux, EndeavourOS, Manjaro, CachyOS, Garuda, and other Arch derivatives

```sh
sudo pacman -Syu --needed base-devel git curl ca-certificates pkgconf gtk4 sqlite
```

Perform the full upgrade shown above to keep the system libraries consistent. Arch's [gtk4 package](https://archlinux.org/packages/extra/x86_64/gtk4/) includes its development files.

### Fedora Workstation, Fedora KDE, and compatible DNF systems

```sh
sudo dnf install gcc git curl ca-certificates pkgconf-pkg-config gtk4-devel sqlite-devel
```

Fedora publishes [gtk4-devel](https://packages.fedoraproject.org/pkgs/gtk4/gtk4-devel/). On RHEL, Rocky Linux, AlmaLinux, CentOS Stream, or another DNF derivative, the same recipe applies only if your enabled repositories provide GTK 4.10+ and its development dependencies. Check the GTK version in step 3; older enterprise releases may not meet the requirement.

### Fedora Atomic desktops: Kinoite and Silverblue

On systems managed by `rpm-ostree`, install the dependencies on the host:

```sh
sudo rpm-ostree install --allow-inactive gcc git curl ca-certificates pkgconf-pkg-config gtk4-devel sqlite-devel
```

Save your work and reboot into the new deployment, then continue with step 2. `--allow-inactive` permits packages already supplied by the base image. Package layering changes take effect after reboot; see the [rpm-ostree administration guide](https://coreos.github.io/rpm-ostree/administrator-handbook/).

These steps use a host build so the installed launcher can access the host's libraries and desktop services. A Toolbox or Distrobox build needs separate runtime/export configuration and is not covered by this recipe. Images managed by a different deployment tool should use that image's documented method for adding the same dependencies.

### openSUSE Tumbleweed, Slowroll, and compatible Leap releases

```sh
sudo zypper refresh
sudo zypper install gcc git curl ca-certificates pkgconf-pkg-config gtk4-devel sqlite3-devel
```

Check that your release supplies GTK 4.10+ before building. Older Leap/SUSE releases may need a distro upgrade. The GTK source package is maintained in the [openSUSE Build Service](https://build.opensuse.org/package/show/GNOME%3AFactory/gtk4).

### Void Linux

```sh
sudo xbps-install -S base-devel git curl ca-certificates pkg-config gtk4-devel sqlite-devel
```

The [Void GTK package definition](https://github.com/void-linux/void-packages/blob/master/srcpkgs/gtk4/template) includes `gtk4-devel`. On musl installations, you can use the distro's `rust` and `cargo` packages if sufficiently recent, then skip the rustup instructions in step 2.

### Gentoo

```sh
sudo emerge --ask dev-vcs/git net-misc/curl app-misc/ca-certificates virtual/pkgconfig '>=gui-libs/gtk-4.10:4' dev-db/sqlite dev-lang/rust
```

Use the C toolchain provided by your Gentoo system. Enable GTK's `wayland` or `X` USE flag for your desktop, and let Portage resolve the corresponding dependencies. Gentoo lists the available GTK versions and flags under [gui-libs/gtk](https://packages.gentoo.org/packages/gui-libs/gtk). A sufficiently recent distro Rust package includes Cargo; skip step 2 if you use it.

### Alpine Linux

Use a current Alpine release with the matching `community` repository enabled:

```sh
sudo apk add build-base git curl ca-certificates pkgconf gtk4.0-dev sqlite-dev rust cargo
```

Build natively with Alpine's Rust/Cargo packages, then skip step 2. Check GTK and Rust versions before continuing. The GTK headers are provided by [gtk4.0-dev](https://pkgs.alpinelinux.org/packages?branch=v3.22&name=gtk4.0-dev). A running graphical session and session D-Bus are required; this does not run as a GUI in a minimal Alpine container.

### NixOS and systems using Nix

Enter a development environment using your configured, current Nixpkgs channel:

```sh
nix-shell -p gcc pkg-config gtk4 sqlite rustc cargo git curl gsettings-desktop-schemas adwaita-icon-theme
```

Skip step 2 and run the shared build and launch commands **inside this shell**. Re-enter the same environment for future launches. See the official [Nix shell documentation](https://nix.dev/tutorials/first-steps/declarative-shell.html).

This is an alternative development-shell recipe. For permanent installation with GTK runtime wrapping, use the [Nix flake](NIX.md).

### Other distributions, including Slackware and Solus

Use your package manager to install Git, curl, CA certificates, a C compiler/linker, `pkg-config`, SQLite3 development files, and **GTK 4.10+ development files** with their dependencies. Package names vary; search for GTK 4 development headers, not GTK 3. Then install a current stable Rust toolchain and follow steps 3–5 below.

If your distribution cannot provide GTK 4.10+, these source instructions cannot work with its stock libraries. Use a newer release or wait for a separately packaged build; do not copy GTK shared libraries from another distro.

## 2. Install Rust

Skip this step if you already have a sufficiently recent Rust/Cargo installation from your distro, Alpine, Gentoo, or the Nix shell above. The project uses Rust's 2024 edition; use current stable Rust to satisfy the locked dependencies as well.

For standard Linux installations, use the installer from the [official Rust installation page](https://rust-lang.org/tools/install/), as your normal user:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/spotlight-rustup-init.sh
sh /tmp/spotlight-rustup-init.sh --profile minimal --default-toolchain stable
. "$HOME/.cargo/env"
```

If you already use rustup, update the stable toolchain with `rustup update stable`. If a different toolchain is selected for the project, run `rustup override set stable` inside the cloned `spotlight` directory before building.

## 3. Download, check requirements, and build

Open a terminal as your normal user. Do not run Cargo or `install.sh` with sudo.

```sh
git clone https://github.com/danny19862025/spotlight.git
cd spotlight
rustc --version
cargo --version
pkg-config --modversion gtk4
pkg-config --atleast-version=4.10 gtk4 && echo "GTK requirement met"
cargo fetch --locked
sh install.sh
```

Stop and resolve any failed command before continuing. `cargo fetch --locked` downloads the versions recorded in `Cargo.lock`. The installer then builds in release mode with `--locked --offline`, using the downloaded cache. The first build can take several minutes.

The installer creates these files for your user:

| Location | Purpose |
| --- | --- |
| `~/.local/bin/spotlight` | Launch command with software rendering enabled |
| `~/.local/lib/spotlight/spotlight` | Compiled application |
| `~/.local/lib/spotlight/UNICODE-LICENSE.txt` | Bundled emoji data license |
| `~/.local/share/applications/spotlight.desktop` | Applications-menu entry |
| `~/.local/share/icons/hicolor/scalable/apps/spotlight.svg` | Application icon |

## 4. Launch and set up your shortcut

```sh
"$HOME/.local/bin/spotlight"
```

You can also search for **Spotlight** in your applications menu. The first launch stays running; launching it again toggles the panel. Escape hides it. Use **Quit Spotlight** to exit. Login autostart is opt-in. Run `"$HOME/.local/bin/spotlight" --autostart` to create `$XDG_CONFIG_HOME/autostart/spotlight.desktop` (or `~/.config/autostart/spotlight.desktop`). It starts the launcher hidden, ready for your shortcut. Use `--no-autostart` to remove the managed entry. You can also opt in during installation with `sh install.sh --autostart`. Existing unrelated entries are preserved.

On **KDE Plasma**, register Meta+Space with:

```sh
"$HOME/.local/bin/spotlight" --install-shortcut
```

If that key is already assigned, Spotlight preserves the existing shortcut. Open **System Settings → Keyboard → Shortcuts**, find Spotlight, and choose an available key or deliberately change the conflicting assignment.

On **GNOME, Xfce, Cinnamon, MATE, or another desktop**, use that desktop's keyboard settings to add a custom shortcut pointing to the **absolute path** of `~/.local/bin/spotlight`. Substitute your actual home directory; shortcut editors may not expand `~` or `$HOME`. The KDE shortcut command does not configure those desktops.

To use the short command `spotlight` in a terminal, ensure `~/.local/bin` is in your PATH. For Bash/Zsh, you can add this to your shell's startup file:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

## 5. Optional desktop features

| Feature | What it needs |
| --- | --- |
| Password lookup | `rbw` with a previously logged-in cached vault and graphical pinentry, or `keepassxc-cli` with a password-protected local database; run `keepass setup` for database/key-file paths |
| Network tools | `ping` (iputils), `dig` (bind-tools/dnsutils), `ss`/`ip` (iproute2), and NetworkManager's `nmcli` for Wi-Fi scanning |
| File vault actions | `gpg` for encryption/decryption; GNU coreutils `sha256sum` and `shred` |
| Wallpaper and accent | KDE Plasma's `plasma-apply-wallpaperimage` and `plasma-apply-colorscheme`; local wallpaper images |
| Clipboard paste queue | Qt 6 Gui and KDE GuiAddons development packages to build `native/build-pastequeue.sh`; installer builds/installs this optional helper when available |
| Clipboard history | KDE Klipper for text and saved images (image database version 3); current images can also be read directly from the clipboard |
| Offline dictionary | Local dictd-format dictionaries; `gzip` for compressed files, or an optional loopback dictd server; see [setup](OFFLINE.md) |
| WASM plugins | Built into Spotlight; plugin authors need a wasm32 compiler, users need no external runtime. See [WASM/SDK setup](WASM.md) |
| Native manifest extensions | The runtime declared by each installed script; see [API](EXTENSIONS.md) |
| Developer tools | `git`, optional GitHub CLI `gh`, Docker/Podman, and optional Espanso for desktop snippet expansion |
| Container logs / exec | Docker or Podman CLI and engine access; exec also needs Konsole, GNOME Terminal or xterm |
| HTTP scratch | `curl` and network access to your requested HTTP(S) endpoint |
| Dotfiles sync | Existing Git clone and Git author identity; private GitHub sync also requires authenticated `gh` |
| Content search | `rg` (ripgrep) |
| Contacts and Akonadi calendar search | Optional Akonadi bridge; local vCard/iCalendar files also work. See [PIM setup](PIM.md) |
| GNOME Calendar/Evolution events | System `/usr/bin/python3`, PyGObject, Evolution Data Server, and `ECal-2.0` / `EDataServer-1.2` introspection libraries with configured calendars. Local-only event creation needs no desktop calendar bridge. See [calendar setup](PIM.md) |
| Window Manager / switcher | KDE KWin; manager shortcuts also use KDE's shortcut service |
| Speaker and microphone controls | WirePlumber's `wpctl` and a running PipeWire audio session |
| Wi-Fi toggle | NetworkManager and `nmcli` |
| Bluetooth toggle | BlueZ and an available Bluetooth adapter |
| Dark mode and Do Not Disturb | KDE Plasma, `plasma-apply-colorscheme`, and the notification applet |
| Empty Trash | KDE KIO's `ktrash6` |
| Color picker | `xdg-desktop-portal` and your desktop's backend with PickColor support; KDE normally uses `xdg-desktop-portal-kde` |
| Screenshots | `xdg-desktop-portal` and a Screenshot-capable desktop backend; optional `tesseract` for OCR and `zbarimg` for QR decoding |
| Music player controls | An MPRIS-capable player on the session D-Bus; no playerctl dependency |
| Native browser history/bookmarks | Python 3 with its standard SQLite module; existing local browser profiles |
| Image conversions / PDF text | `vips` (preferred) or `ffmpeg` with WebP support; `pdftotext` for PDFs |
| Image palettes | Built-in Pixbuf image decoder support |
| Currency conversion | curl and an internet connection |
| Alarm sounds | `paplay` with a working PulseAudio-compatible server and the freedesktop sound theme, or `canberra-gtk-play` as fallback |
| Open notes in Obsidian | An existing Obsidian vault and Obsidian's URI handler |

For silent alarms, use your distro's package search to find the package providing `paplay` (often `pulseaudio-utils` or `pulseaudio`), plus `sound-theme-freedesktop`. PipeWire desktops can use their PulseAudio compatibility service. You do not need to replace a working audio server. Use the alarm dialog's **Test Sound** button to check it.

## Updating Spotlight

From your original checkout, after saving work and quitting Spotlight:

```sh
git pull --ff-only
cargo fetch --locked
sh install.sh
"$HOME/.local/bin/spotlight"
```

Install any newly required system dependencies first. User data remains in `$XDG_DATA_HOME/spotlight`, or `~/.local/share/spotlight` by default. Notes, settings, and history are not bundled with the repository or uploaded by the installer.

## Troubleshooting

| Problem | What to do |
| --- | --- |
| `cargo` or `rustc` not found | Open a new terminal after installing Rust, or run `. "$HOME/.cargo/env"` for a rustup installation. |
| Unsupported Rust edition or dependency needs newer Rust | Update stable Rust with rustup, or update your distro's Rust/Cargo packages. |
| `pkg-config` not found | Install your distro's `pkg-config`/`pkgconf` package. |
| `gtk4.pc` missing or GTK too old | Install GTK 4 development headers and check `pkg-config --modversion gtk4`. GTK must be at least 4.10. |
| Offline dependency/download error during installation | Run `cargo fetch --locked` successfully with internet access, as the same user, then rerun `sh install.sh`. |
| Compiler killed or build runs out of memory | Retry with `CARGO_BUILD_JOBS=1 sh install.sh`; close other memory-heavy programs or provide swap if needed. |
| `spotlight: command not found` | Use `"$HOME/.local/bin/spotlight"` or add `~/.local/bin` to your PATH. |
| Cannot open display or connect to session bus | Run inside your logged-in graphical desktop as your normal user, not through sudo, a bare SSH session, or a headless container. |
| No clipboard history or window actions | These features require the corresponding KDE services; see the desktop support section. |
| Color picker unavailable | Check your running desktop portal backend and its PickColor support. |
| Menu entry not visible immediately | Launch by its full path; log out and back in if your desktop has not refreshed its application menu. |

To check the Rust code after installing dependencies:

```sh
cargo test --locked --offline
```

## Uninstall

If enabled, remove login startup first with `"$HOME/.local/bin/spotlight" --no-autostart`.

Quit Spotlight, then remove only its installed program files:

```sh
rm -f "$HOME/.local/bin/spotlight"
rm -f "$HOME/.local/lib/spotlight/spotlight" "$HOME/.local/lib/spotlight/UNICODE-LICENSE.txt"
rmdir "$HOME/.local/lib/spotlight"
rm -f "$HOME/.local/share/applications/spotlight.desktop"
rm -f "$HOME/.local/share/kglobalaccel/spotlight.desktop"
rm -f "$HOME/.local/share/icons/hicolor/scalable/apps/spotlight.svg"
```

Remove any custom keyboard shortcut in your desktop's settings. Your local notes and settings remain under your Spotlight data directory. Notes saved in an Obsidian vault remain in that vault.
