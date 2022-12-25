# Miaj Nix-Agordoj 

[![ci.codeberg.org status](https://ci.codeberg.org/api/badges/wolfangaukang/nix-agordoj/status.svg)](https://ci.codeberg.org/wolfangaukang/nix-agordoj/)
[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

Here are my Nix/NixOS settings. For a better experience, please use Nix Flakes.

Structure:
- `docs/`: Contains docs regarding any significant processes that need to be explained in details.
- `home/`: Contains configurations related to home directory. Basically you will find `home-manager` configs.
  - Contains user definitions, modules and profiles.
- `hosts/`: Build setup for my hosts. Has a `common` directory to share anything related. The ones currently active are:
  - `eyjafjallajokull`
  - `holuhraun`
  - `katla` (Using NixOS-WSL)
  - `raudholar` (A VM)
- `lib/`: Extra functions created to auxiliate with stuff. For example, here is defined how the systems are built.
- `misc/`: Anything non related to Nix, like my dotfiles (imported as a submodule).
- `overlays/`: Self-explanatory. Contains basic overlays. 
- `pkgs/`: Packages I generally use to maintain by myself because of urgency or to make them available through NUR (WIP).
- `system/`: NixOS related configurations.
  - Contains user definitions, modules and profiles.
- `templates/`: Useful for new projects. Currently, there are only for Python and Bash projects.
- `flake.nix`: My flake. Currently using [flake-utils-plus](https://github.com/gytis-ivaskevicius/flake-utils-plus) as Flake framework. 
  - **NOTE:** Consider using `path:.` as flake url, until submodules can be considered.
- `default.nix`: This is for the old way of importing stuff from this repo. Only supports modules and pkgs.
