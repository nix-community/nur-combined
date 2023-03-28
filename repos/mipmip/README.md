# Nix, NixOS and Home Manager for mipmip's machine park

This is my mono-repository for my machines configuration and my dotfiles.

## Features

- multi machine
- flakes
- Custom patched Suckless Terminal (st)

### Mentional NUR's
- A 32 bits Brother printer driver
- Some Gnome Extensions packed directly from Github (useful is maintainers keep behind supporting the latest Gnome Versions)
- mip.rs, a fast and suckless markdown viewer written in Rust.
- WIP: Skull, a tool for managing git working copies on demand.
- some NUR crystal apps

## Usage

clone:

```
cd ~
git clone --recurse-submodules git@github.com:mipmip/nixos.git
cd /etc
mv /etc/nixos /etc/nixos.bak
sudo ln -s /home/pim/nixos nixos
```

nixos-rebuild:

```
cd /etc/nixos
sudo nixos-rebuild switch --flake .#ojs
```

Home Manager:

```
cd /etc/nixos
home-manager switch  --flake .#pim@ojs --impure
```

### TODO

- [x] fix NUR url, maybe nur.nix
- [x] home manager flake
- [ ] public features and documentation Usage
- [ ] setup firefox profiles: https://discourse.nixos.org/t/help-setting-up-firefox-with-home-manager/23333
- [ ] install firefox language packs from nur
- [ ] delete i-am-desktop
- [ ] new method i-am-secondbrain
- [ ] tmux A or B

Lego1
- [x] swap alt/win keys
- [x] commit nixos
- [ ] swap ctrl/fn keys
- [ ] wayland and scaling

Rodin
- [ ] commit nixos

### MacOS Provisioning

For macOS provisioning I only use Home-Manager from Nix. Cli tools are declared
in home-manager/programs/macos-bundle.nix. Other mac-apps are in
`home-manager/files-macos/Brewfile`. Install them with `brew bundle install`

- install [Homebrew](https://brew.sh/)
- install Nix on mac](https://nixos.org/download.html#nix-install-macos).
- then install Home Manager. See [Home Manager Manual](https://nix-community.github.io/home-manager/index.html#sec-install-standalone)

### NixOS Programming

#### Check for missing modules

when refactoring it's nice to quickly see which hosts have missing modules. To
see this run:

```
./RUNME.sh missing_modules
```

### Home-Manager Depreciated (remove once tested)

Make sure home-manager is installed. On Mac I home-manager as single user
install. On nixos home-manager is installed automatically.

Create home dir conf:

```sh
mkdir -p ~/.config/nixpkgs
echo "{\n  allowUnfree = true;\n}" > ~/.config/nixpkgs/config.nix
```

Make the symlink `~/.config/nixpkgs/home.nix` pointing to one of the home-confs
located in `~/nixos/home-manager/`


```sh
ln -s ~/nixos/home-manager/home-[some-home-conf].nix ~/.config/nixpkgs/
```

Test configuration with:

```
home-manager switch
```

### Home-Manager

```
home-manager switch  --flake .#pim --impure
```

## Features

### Linux Desktop Highlights

I use GNOME as desktop environment with a few extensions to give me some
features I'm used too from the time I used macOS as primary OS.

### Programming and writing

I payed a lot of time optimizing my terminal and vim configuration. I use
[St](https://st.suckless.org) with a few patches for better aesthetics.

My St/Vim writing configuration has a larger line height, a dedicated font, a
pure white background together with a grayscale writing theme. Here's a pic
showing my writing environment.

![writing in vim](./docs/gelukkigmetvim.png)

## Private

Stage 2 of my security strategy is a git submodule with some configurations not
relevant for public. This repo does not contain passwords or secrets.
