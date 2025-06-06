# nixos-config

My NixOS configuration/dotfiles/rules.

## Programs

The `modules` dir contains details about the programs that need additional
configurations. Other programs that can be simply included in
`environment.systemPackages` are placed in `hosts/*/default.nix`.

| Type           | Program                                             |
| -------------- | --------------------------------------------------- |
| Editor         | [Vscode](https://code.visualstudio.com/)            |
| Launcher       | [Rofi-wayland](https://github.com/lbonn/rofi)       |
| Shell          | [Fish](https://fishshell.com/)                      |
| Status Bar     | [Waybar](https://github.com/alexays/waybar)         |
| Terminal       | [Alacritty](https://github.com/alacritty/alacritty) |
| Window Manager | [Niri](https://github.com/YaLTeR/niri)              |
| Browser        | [Firefox](http://www.mozilla.com/en-US/firefox/)    |
| Music Player   | [Spotify](https://www.spotify.com/)                 |

## Themes

| Type          | Name                                                                                                                    |
| ------------- | ----------------------------------------------------------------------------------------------------------------------- |
| GTK Theme     | [Orchis](https://github.com/vinceliuice/Orchis-theme)                                                                   |
| Terminal Font | [FantasqueSansMono Nerd Font Mono](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FantasqueSansMono) |

## Structure

Here is an overview of the folders' structure:

- `hosts`: The NixOS configurations.
- `lib`: Some utils to build outputs in `default.nix` and `flake.nix`.
- `modules`: Configurations of programs.
  - `**/default.nix`: NixOS module.
  - `**/home.nix`: Home manager module.
  - `**/overlay.nix`: NixOS overlay.
  - `**/package.nix`: Package source.
  - `**/packages.nix`: Package set source.
  - `**/update.sh`: The shell script to update package's version.
- `outputs`: Flake outputs.
- `default.nix`: NUR main.
- `flake.nix`: Flake main.
