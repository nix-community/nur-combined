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
| Window Manager | [Sway](https://swaywm.org/)                         |
| Browser        | [Firefox](http://www.mozilla.com/en-US/firefox/)    |
| Music Player   | [Spotify](https://www.spotify.com/)                 |

## Themes

| Type          | Name                                                                                                                    |
| ------------- | ----------------------------------------------------------------------------------------------------------------------- |
| GTK Theme     | [Orchis](https://github.com/vinceliuice/Orchis-theme)                                                                   |
| Terminal Font | [FantasqueSansMono Nerd Font Mono](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FantasqueSansMono) |

## Structure

Here is an overview of the folders' structure:

```
.
├── hosts
│   ├── local
│   └── n1
├── lib
├── modules
│   ├── avahi
│   ├── bluetooth
│   ├── clash
│   ├── common
│   ├── direnv
│   ├── extlinux
│   ├── fcitx5
│   ├── firefox
│   ├── fish
│   ├── fonts
│   ├── genymotion
│   ├── git
│   ├── grub
│   ├── gtk
│   ├── lib
│   ├── neovim
│   ├── nix
│   ├── nix-nss-mdns
│   ├── nix-serve
│   ├── openfortivpn
│   ├── pipewire
│   ├── podman
│   ├── qinglong
│   ├── safeeyes
│   ├── smartdns
│   ├── spotify
│   ├── sway
│   ├── users
│   ├── vscode
│   └── waybar
├── outputs
│   ├── colmena.nix
│   ├── devShells.nix
│   ├── formatter.nix
│   ├── lib.nix
│   ├── overlay.nix
│   ├── overlays.nix
│   └── packages.nix
├── default.nix
└── flake.nix
```

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

## Usage

You can have a look at the available flake outputs before getting started.

```console
$ nix flake show github:slaier/nixos-config
github:slaier/nixos-config/e2b0f58d7a9bdbe737d5503071e01065b1ef5c58
├───colmena: unknown
├───devShells
│   ├───aarch64-linux
│   │   └───default: development environment 'nix-shell'
│   └───x86_64-linux
│       └───default: development environment 'nix-shell'
├───formatter
│   ├───aarch64-linux: package 'nixpkgs-fmt-1.3.0'
│   └───x86_64-linux: package 'nixpkgs-fmt-1.3.0'
├───lib: unknown
├───overlay: Nixpkgs overlay
├───overlays
│   ├───arkenfox-userjs: Nixpkgs overlay
│   ├───nix-nss-mdns: Nixpkgs overlay
│   ├───podman: Nixpkgs overlay
│   ├───safeeyes: Nixpkgs overlay
│   ├───smartdns: Nixpkgs overlay
│   ├───spotify: Nixpkgs overlay
│   ├───sway: Nixpkgs overlay
│   ├───uboot-phicomm-n1: Nixpkgs overlay
│   ├───vscode-extensions: Nixpkgs overlay
│   ├───wavefox: Nixpkgs overlay
│   └───wrapper: Nixpkgs overlay
└───packages
    ├───aarch64-linux
    │   ├───arkenfox-userjs: package 'arkenfox-userjs-112.0'
    │   ├───nix-nss-mdns: package 'nix-2.11.1'
    │   ├───uboot-phicomm-n1: package 'uboot-phicomm-n1-unstable-2023-04-29'
    │   ├───vscode-extensions-ms-vscode-remote-remote-containers: package 'vscode-extension-ms-vscode-remote-remote-containers-0.269.0'
    │   └───wavefox: package 'wavefox-1.6.113'
    └───x86_64-linux
        ├───arkenfox-userjs: package 'arkenfox-userjs-112.0'
        ├───nix-nss-mdns: package 'nix-2.11.1'
        ├───uboot-phicomm-n1: package 'uboot-phicomm-n1-unstable-2023-04-29'
        ├───vscode-extensions-ms-vscode-remote-remote-containers: package 'vscode-extension-ms-vscode-remote-remote-containers-0.269.0'
        └───wavefox: package 'wavefox-1.6.113'
```

As well as all the declared flake inputs.

```console
$ nix flake metadata github:slaier/nixos-config
Resolved URL:  github:slaier/nixos-config
Locked URL:    github:slaier/nixos-config/c3277d2d83b43e10711e1b3500da1884f4e680b7
Path:          /nix/store/8vq8lmgsynccfwr8gp8yyf8k93msds25-source
Revision:      c3277d2d83b43e10711e1b3500da1884f4e680b7
Last modified: 2023-05-10 23:06:53
Inputs:
├───darkmatter-grub-theme: gitlab:VandalByte/darkmatter-grub-theme/73edab7a1e1ab7ecab694c03eb335d808c40b35d
│   └───nixpkgs follows input 'nixpkgs'
├───haumea: github:nix-community/haumea/d817a76c8846b97dd665889c24c25c9e077af268
│   └───nixpkgs follows input 'nixpkgs'
├───home-manager: github:nix-community/home-manager/f9edbedaf015013eb35f8caacbe0c9666bbc16af
│   ├───nixpkgs follows input 'nixpkgs'
│   └───utils: github:numtide/flake-utils/5aed5285a952e0b949eb3ba02c12fa4fcfef535f
├───impermanence: github:nix-community/impermanence/df1692e2d9f1efc4300b1ea9201831730e0b817d
├───nix-index-database: github:Mic92/nix-index-database/e3e320b19c192f40a5b98e8776e3870df62dee8a
│   └───nixpkgs: github:nixos/nixpkgs/03aec194125de1fd6f486d323cee872bb4be88cc
├───nixpkgs: github:NixOS/nixpkgs/cc45a3f8c98e1c33ca996e3504adefbf660a72d1
├───nixpkgs-unstable: github:NixOS/nixpkgs/0d8145a5d81ebf6698077b21042380a3a66a11c7
└───nur: github:nix-community/NUR/24b7e88aa797c61667410e86baf04500f450076
```

Using overlays and packages in your configuration is fairly straight forward.

In your `flake.nix` add slaier.overlay to your overlay list:

```nix
{
  inputs = {
    # ...
    slaier.url = github:slaier/nixos-config;
    slaier.inputs.nixpkgs.follows = "nixpkgs";
    slaier.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    slaier.inputs.home-manager.follows = "home-manager";
    # ...
  };

  outputs = { self, nixpkgs, slaier }: {
    nixosConfigurations.myConfig = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        ({
          nixpkgs.overlays = [
            slaier.overlay
            # Or you only want to import single overlay:
            # slaier.overlays.vscode-extensions
          ];
        })
      ];
    };
  };
}
```

I am not sure the outputs of flake can work fine in your configurations. If you
have problems when using them, please create a issue and then I will fix it.
