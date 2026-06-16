# Konsave Configuration

Konsave is a CLI tool for exporting and applying KDE Plasma layouts, themes, and rules, with more details on GitHub at https://github.com/Prayag2/konsave.

This directory mirrors `$HOME/.config/konsave` so Plasma customizations are tracked in git before they touch the live profile.

## What this configuration includes

- **Configs** – `conf.yaml` backs up every major KDE RC (`kdeglobals`, `kwinrc`, `plasmarc`, `kglobalshortcutsrc`, `ksmserverrc`, `dolphinrc`, `konsolerc`, Latte Dock, Kvantum, Breeze/Oxygen/Lightly themes, hotkeys, etc.) plus GTK themes so both Plasma and supporting toolkits stay in sync.
- **App layouts** – Stored actions for `dolphin` and `konsole` under `$HOME/.local/share/kxmlgui5` preserve any panel/toolbars tweaks that wander around.
- **Exported assets** – Plasma, KWin, Konsole, fonts, color schemes, Aurorae decorations, icons, and wallpapers live under `$HOME/.local/share`, while `.fonts`, `.themes`, and `.icons` in `$HOME` come along with each profile to keep the visual stack consistent.

The `conf.yaml` structure is the reference source for what gets saved vs. exported; edit it directly if you need to add more directories or assets.

## Installation

```sh
ln -sfn "$HOME/Configs/konsave" "$HOME/.config/konsave"
```

## Everyday use

- `konsave -s ahmet-cetinkaya -f` writes the current session into the `ahmet-cetinkaya` profile defined here.
- `konsave -a ahmet-cetinkaya` applies the stored settings (log out and back in for Plasma widgets and KWin rules to refresh).
- `konsave -h`/`--help`, `-v`/`--version`, and `-w` (wipe all) offer the rest of the CLI.
