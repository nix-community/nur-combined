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

### Add Agenix file

1. add file registration in secrets/secrets.nix
2. cd secrets
3. create file or edit file `agenix -e aws-credentials-copy.age`
4. add file purpose to modules/nix-agenix.nix

example: `agenix -i ~/.ssh/id_ed25519 -e aws-credentials-copy.age`

### TODO

- [x] fix NUR url, maybe nur.nix
- [x] home manager flake
- [x] delete i-am-desktop
- [x] new method i-am-secondbrain
- [ ] public features and documentation Usage
- [ ] setup firefox profiles: https://discourse.nixos.org/t/help-setting-up-firefox-with-home-manager/23333
- [ ] install firefox language packs from nur
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


# Pine Phone Pesto

## Build Image

Build from any nix machine with:

```sh
nix build './#pinephone-img'
```

If nix complains about some "experimental features", then add to the host's nix
config: `nix.extraOptions = "experimental-features = nix-command flakes";`

flash with:
```sh
sudo dd if=$(readlink result) of=/dev/sdb bs=4M oflag=direct conv=sync status=progress
```

Then insert the SD card, battery into your pinephone and hold the power button
for a few seconds until the power LED turns red. after releasing the power
button, the LED should turn yellow, then green. you'll see the "mobile NixOS"
splash screen and then be dropped into a TTY login prompt.


## Update with copy-closure

build on host machine

```
nix build .\#nixosConfigurations.pinephone.config.system.build.toplevel --print-out-paths
```

copy to pinephone

```
nix-copy-closure --to root@192.168.13.103 ./result
```

on pinephone 

```
/nix/store/nid92px7zybggpxh5j6bwzcpmjh10p8h-nixos-system-nixos-22.05.20220520.dfd8298/bin/switch-to-configuration switch
```

# Nix-on-Droid (fairPhone)

## Setup nix-on-droid

ln -s ~/nixos/nix-on-droid ~/.config/

## Apply nix config

nix-on-droid switch -F ~/.config/nix-on-droid/flake.nix

## SSH Connect

ssh nix-on-droid@xxxxx -p8022
