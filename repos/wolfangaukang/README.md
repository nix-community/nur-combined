# Miaj Nix-Agordoj 

[![ci.codeberg.org status](https://ci.codeberg.org/api/badges/wolfangaukang/nix-agordoj/status.svg)](https://ci.codeberg.org/wolfangaukang/nix-agordoj/)
[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

Here are my Nix/NixOS settings. For a better experience, please use Nix Flakes.

Structure:
- `docs/`: Contains docs regarding any significant processes that need to be explained in details.
- `hosts/`: Build setup for my hosts. The ones currently active are (the rest are there as reference only):
  - `eyjafjallajokull`
  - `holuhraun`
- `misc/`: Anything non related to Nix, like my dotfiles (imported as a submodule).
- `modules/`: Any custom modules for NixOS/Home-Manager created by me.
- `overlays/`: Self-explanatory. Contains basic overlays. 
- `pkgs/`: Packages I generally use to maintain by myself because of urgency or to make them available through NUR (WIP).
- `profiles/`: See them as settings that should be this way (import and that's it). In case I need to modify values, I'd rather write a module :P. There are for both NixOS/Home-Manager.
- `templates/`: Useful for new projects. Currently, there are only for Python and Bash projects.
- `flake.nix`: My flake. Best way to build the systems stated here
  - **NOTE:** Consider using `path:.` as flake url, until submodules can be considered.
- `default.nix`: This is for the old way of importing stuff from this repo. Only supports modules and pkgs.
