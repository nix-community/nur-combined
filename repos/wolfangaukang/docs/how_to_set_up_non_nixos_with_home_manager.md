# How To Set Up a non-NixOS system with Home Manager

## 1. Install Nix on the system
- Follow the instructions from [here](https://nixos.org/download.html#nix-quick-install).
## 2. Set up Flakes
- Install NixUnstable (`nix-env -f "<nixpkgs>" -iA nixUnstable`)
  - Do not install `nixFlakes` as it is obsolete
- Optionally, you can add this to your `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`:
    - `experimental-features = nix-command flakes`
## 3. Clone this dotfiles repo and go there
- Run `git clone https://gitlab.com/WolfangAukang/dotfiles`
- Move to the dotfiles directory (`cd dotfiles`)
## 4. Build the flake
- Run `nix build .#profile_name --impure`
  - Replace *profile_name* with one of the profiles indicated at `outputs.homeManagerConfigurations` on `flake.nix` 
## 5. Activate the results
- If the previous command was successful, then run `./result/activate`


