# Miaj Nix-Agordoj 

[![ci.codeberg.org status](https://ci.codeberg.org/api/badges/wolfangaukang/nix-agordoj/status.svg)](https://ci.codeberg.org/wolfangaukang/nix-agordoj/)
[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

Here are my Nix/NixOS settings. For a better experience, please use Nix Flakes.

Structure:
- `docs/`: Contains docs regarding any significant processes that need to be explained in details.
- `home/`: Contains configurations related to home directory. Basically you will find `home-manager` configs.
  - Contains user definitions, modules and profiles.

- `lib/`: Extra functions created to auxiliate with stuff. For example, here is defined how the systems are built.
- `overlays/`: Self-explanatory. Contains basic overlays. 
- `pkgs/`: Packages I generally use to maintain by myself because of urgency or to make them available through NUR (WIP).
- `shells/`: Contains definitions for development shells used.
- `system/`: NixOS related configurations, like build setup for my hosts. Has a `common` directory to share anything related. The ones currently active are:
  - `arenal`
  - `irazu`
  - `pocosol/vm` (A VM)
- `templates/`: Useful for new projects. Currently, there are only for Python and Bash projects.
- `flake.nix`: My flake.
- `default.nix`: This is for the old way of importing stuff from this repo. Only supports modules and pkgs.

General considerations:
- My dotfiles (non-Nix related stuff) are located [here](https://codeberg.org/wolfangaukang/dotfiles). With flakes, I can reference non-flake repositories instead of using submodules (which is not very compatible with flakes unless referencing the repository as `path:.#`, which can become tedious).
