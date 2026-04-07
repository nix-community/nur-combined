# Spektrafilm and Spektrafilm in Art Nix derivations

First, make sure you have nix (either install it from https://nixos.org/download/ or use NixOS/home-manager).

How to install Spektrafilm

```
nix profile add --extra-experimental-features nix-command --extra-experimental-features flakes github:rafaelcgs10/spektrafilm-art#spektrafilm
```

How to install Art with Spektrafilm
```
nix profile add --extra-experimental-features nix-command --extra-experimental-features flakes github:rafaelcgs10/spektrafilm-art#spektrafilm-art
```

Note: I only tested this on Fedora Linux with Nix, and NixOS.

The `ART_agx_film.json` file can be located with:

```
find /nix/store/ -type f -name "ART_agx_film.json" | grep -v source
```

I need to improve the location of this file, or automate it being set in Art.
