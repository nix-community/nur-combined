# nurpkgs

My Nix User Repository. Mainly re-packaging other people's code hoping to get upstreamed at some point, but also some of my own personal packages.

## Outputs

`overlay.default`

```
$ nix repl .
> pkgs = import <nixpkgs> { overlays = [ overlays.default ]; }
> pkgs.nur.repos.josh
```

```nix
# NixOS or Home Manager module
{
  nixpkgs.overlays = [
    josh-nurpkgs.overlays.default
  ];
}
```
