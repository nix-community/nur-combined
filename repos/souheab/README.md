# Souheab's NUR packages

My personal package repository for the [Nix User Repository (NUR)](https://github.com/nix-community/NUR).

## Packages

| Attribute | Description |
| --- | --- |
| `anything-llm` | [AnythingLLM](https://github.com/Mintplex-Labs/anything-llm), an all-in-one AI application for documents and agents |
| `claude-desktop` | [Claude Desktop](https://support.claude.com/en/articles/10065433-install-claude-desktop), Anthropic's official Linux beta for x86_64 and ARM64 |
| `koharu` | [Koharu](https://github.com/koharu-rs/koharu), an AI-powered manga translator for Linux x86_64 and ARM64 |
| `open-pencil` | [OpenPencil](https://github.com/open-pencil/open-pencil), an open-source design editor |

## Claude Desktop

Claude Desktop is proprietary and requires allowing unfree packages. To run it
from this checkout:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix run .#claude-desktop --impure
```

With NUR configured, add `nur.repos.souheab.claude-desktop` to your packages and
enable `nixpkgs.config.allowUnfree = true;` (or an appropriate allowlist).

The package uses the official Debian release inside a Nix FHS environment and
includes desktop entries, icons, QEMU, and UEFI firmware. Cowork additionally
requires hardware virtualization and access to `/dev/kvm`; on NixOS, add your
user to `users.users.<name>.extraGroups = [ "kvm" ];`, then log out and back in.
A desktop portal and a Secret Service provider such as GNOME Keyring should be
configured through your desktop environment. Updates are managed by Nix.

## Koharu

Run `nix run .#koharu` from this checkout, or add `nur.repos.souheab.koharu`
to your packages with NUR configured.

The package wraps the official Debian release in a Nix FHS environment and
includes the desktop launcher and icons. Koharu downloads models and ML
runtimes on demand, so their first use requires network access and additional
disk space. Install application updates through Nix.

The editor requires Vulkan-capable graphics drivers and uses X11 (XWayland
on Wayland desktops). On NixOS, enable `hardware.graphics.enable = true;`
and configure the appropriate driver for your GPU. GPU inference support
depends on the hardware and upstream runtime requirements.
