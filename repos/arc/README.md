[![ci-badge][]][ci]

A collection of packages and modules for Nix, NixOS, and home-manager.

```bash
nix run nixpkgs.cachix -c cachix use arc
```

## Organization

The following top-level attrs are exposed:

- `arc.packages` exposes all packages available
  - `arc.packages.groups` of packages can also be found here, such as `vimPlugins`
- `arc.build` is for build support helper functions and similar
- `arc.shells` contains some ready-made customizeable shell environments
  - `arc.shells.rust.stable` contains a bunch of stuff
  - `arc.shells.rust.nightly` is an occasionally-pinned unstable rust shell
- `arc.lib` contains library functions
- `arc.modules` can be used to import modules for nixos and other systems
  - `arc.modules.nixos` contains [nixos](https://nixos.org/) modules
  - `arc.modules.home-manager` contains [home-manager](https://github.com/nix-community/home-manager) modules
  - `arc.modules.misc` contains generic or helper modules that may be used in all contexts
- `arc.overlays` can be applied on top of nixpkgs
  - `arc.overlays.arc` adds the channel as `pkgs.arc`
  - `arc.overlays.lib` adds `arc.lib` to `pkgs.lib`
  - `arc.overlays.python` adds `pkgs.pythonOverrides` that can be used to modify python package sets
    - it also populates it with packages included with the channel
  - `arc.overlays.shells` adds `pkgs.shells`
  - `arc.overlays.fetchurl` replaces `pkgs.fetchurl` with a builtin nix fetcher
  - `arc.overlays.overrides` replaces some packge derivations with [the arc overrides](pkgs/overrides.nix)
- `arc.pkgs` overlays the whole channel on top of nixpkgs, generally including all of the above

### Packages

[NUR package list](https://nur.nix-community.org/repos/arc/)

To find out what packages are available...

```bash
nix-env -f. -qa '*'
nix build -f. packages.<TAB>
```

[ci-badge]: https://github.com/arcnmx/nixexprs/workflows/arc-nixexprs/badge.svg
[ci]: https://github.com/arcnmx/nixexprs/actions?workflow=arc-nixexprs
