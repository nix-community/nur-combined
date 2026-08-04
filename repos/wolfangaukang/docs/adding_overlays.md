# How to add an overlay?

**NOTE:** Use this guide as a reference:
- [NixOS guide about overlays](https://nixos.wiki/wiki/Overlays)
- [NixOS: The DOs and DON’Ts of nixpkgs overlays](https://blog.flyingcircus.io/2017/11/07/nixos-the-dos-and-donts-of-nixpkgs-overlays/) 

To add an overlay:
- On a flakes level, add the imports to `flake.nix` file to the overlays list like:
```
overlays = [
  ...
  (import ./nix/overlays/file.nix)
  ...
];
```
- On a single system level, do the following:
  - On `nix/systems/system/flake.nix`, rewrite the overlay like this:
```
overlays = overlays ++ [
  (import ./nix/overlays/file.nix)
];
```
  - Also, on the `nix/systems/system/home-manager.nix`, add the package to the `home.packages` section.
