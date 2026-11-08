<div align="center">

# `dotfiles`

[![GitHub stars](https://img.shields.io/github/stars/ahmet-cetinkaya/dotfiles?style=flat&logo=github)](https://github.com/ahmet-cetinkaya/dotfiles/stargazers)
[![GitHub last commit](https://img.shields.io/github/last-commit/ahmet-cetinkaya/dotfiles?style=flat&logo=git&logoColor=white)](https://github.com/ahmet-cetinkaya/dotfiles/commits/main)
[![GitHub license](https://img.shields.io/github/license/ahmet-cetinkaya/dotfiles?style=flat)](https://github.com/ahmet-cetinkaya/dotfiles/blob/main/LICENSE)

Personal configuration files for my NixOS machines — managed declaratively and synced across desktops.

![NixOS](https://img.shields.io/badge/NixOS-5277C3?style=flat&logo=nixos&logoColor=white)

</div>

## ✨ Highlights

- **Declarative NixOS**: Flake-based, modular system configuration with custom packages and Home Manager.
- **NixOS first**: App configs at the repo root are linked by Home Manager.
- **Consistent shell**: Zsh + Starship prompt, with Fastfetch and shared aliases.
- **Editors ready**: Neovim, VSCodium, and Zed settings.
- **Archive**: Configs I no longer use are kept in `.archive/` with their history.

## 📂 Structure

```text
.
├── nixos/            # Flake-based NixOS configuration (see nixos/README.md)
│
├── kitty/            # Terminal emulator
├── zsh/              # Shell + plugins (submodules)
├── starship/         # Prompt
├── fastfetch/        # System info
│
├── neovim/           # Neovim config
├── vs-codium/        # VSCodium settings
├── zed/              # Zed editor settings
│
├── vesktop/          # Discord client settings
├── konsave/          # KDE config snapshots
│
├── agent-ctrl/       # AI agent profiles and settings
└── .archive/         # Unused configs (Arch, Hyprland stack, Windows tools, Firefox, prettier)
```

## 🚀 Getting Started

Clone the repository with its submodules:

```bash
git clone --recurse-submodules https://github.com/ahmet-cetinkaya/dotfiles.git ~/Configs
cd ~/Configs
```

> [!TIP]
> If you already cloned without `--recurse-submodules`, run
> `git submodule update --init --recursive` to fetch the Zsh plugins.

### 🐧 NixOS

The NixOS configuration is fully declarative. To apply it on the main host (`karakiz`):

```bash
sudo nixos-rebuild switch --flake ./nixos#karakiz
```

See [nixos/README.md](nixos/README.md) for details on structure, custom packages, and updating inputs.

## 🛠️ Maintenance

Run repository maintenance through `make`:

```bash
make format             # Format config files
make lint               # Lint shell and Nix configuration
```

Agent and contribution guidelines are documented in [AGENTS.md](AGENTS.md).

## 🤝 Contributing

These are personal dotfiles, but feel free to open an issue or borrow anything useful. Suggestions and fixes are always welcome.

## 📄 License

Released under the [MIT License](LICENSE) unless a subdirectory states otherwise.
