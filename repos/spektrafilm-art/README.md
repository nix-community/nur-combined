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

## Darktable with Spektrafilm

This repo also packages [darktable](https://www.darktable.org) built from the
[`spektrafilm-draft`](https://github.com/Arecsu/darktable/tree/spektrafilm-draft)
branch of the [Arecsu/darktable](https://github.com/Arecsu/darktable) fork, which
adds a **native C** spektrafilm module (`src/iop/spektrafilm.c`). Unlike the ART
integration above, this does **not** depend on the spektrafilm Python package — it
only needs a runtime data pack.

Install darktable with the spektrafilm module:

```
nix profile add --extra-experimental-features nix-command --extra-experimental-features flakes github:rafaelcgs10/spektrafilm-art#darktable-spektrafilm
```

### Required: film & print data pack

The module reads its spectral LUT and film/paper profiles from
`~/.config/darktable/spektrafilm/` (Linux). This repo pins the prebuilt pack as
the `spektrafilm-data-pack` output. Link it into place, e.g. with home-manager:

```nix
# darktable-spektrafilm and its data pack, from this flake's packages
home.packages = [ spektrafilmPackages.darktable-spektrafilm ];
home.file.".config/darktable/spektrafilm".source =
  spektrafilmPackages.spektrafilm-data-pack;
```

Or manually, without home-manager:

```
mkdir -p ~/.config/darktable
ln -sfn "$(nix build --no-link --print-out-paths github:rafaelcgs10/spektrafilm-art#spektrafilm-data-pack)" \
  ~/.config/darktable/spektrafilm
```

The pack is a prebuilt artifact (the exporter that generates it from the Python
package is not public yet). When the module is updated, bump both
`pkgs/darktable-spektrafilm/darktable-spektrafilm.nix` (`src.rev`) and
`pkgs/darktable-spektrafilm/data-pack.nix` (the pinned zip) together.

Note: I only tested this on Fedora Linux with Nix, and NixOS.

The `ART_agx_film.json` file can be located with:

```
find /nix/store/ -type f -name "ART_agx_film.json" | grep -v source
```

I need to improve the location of this file, or automate it being set in Art.
