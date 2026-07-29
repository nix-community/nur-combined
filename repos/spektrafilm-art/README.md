# Spektrafilm Nix Packages

This flake packages:

- `spektrafilm`: the upstream Spektrafilm Python/Qt app.
- `spektrafilm-art`: ART patched/wrapped to use Spektrafilm LUT generation.
- `darktable-spektrafilm`: darktable built from the native Spektrafilm module PR.
- `darktable-spektrafilm-ai`: the same darktable package with darktable's AI option enabled and all bundled AI models linked automatically.
- `spektrafilm-data-pack`: the runtime film/print data pack required by the darktable module.

Install Nix first if needed: https://nixos.org/download/.

All commands below use flakes:

```sh
--extra-experimental-features 'nix-command flakes'
```

## Run Without Installing

Run Spektrafilm:

```sh
nix run --extra-experimental-features 'nix-command flakes' github:rafaelcgs10/spektrafilm-art-darktable#spektrafilm
```

Run ART with Spektrafilm:

```sh
nix run --extra-experimental-features 'nix-command flakes' github:rafaelcgs10/spektrafilm-art-darktable#spektrafilm-art
```

Run darktable with the native Spektrafilm module:

```sh
nix run --extra-experimental-features 'nix-command flakes' github:rafaelcgs10/spektrafilm-art-darktable#darktable-spektrafilm
```

Run darktable with Spektrafilm and darktable AI enabled:

```sh
nix run --extra-experimental-features 'nix-command flakes' github:rafaelcgs10/spektrafilm-art-darktable#darktable-spektrafilm-ai
```

The wrapper creates `~/.config/darktable/spektrafilm` automatically and points it at the bundled data pack. It only replaces that path when it is missing or already a symlink; it will not overwrite a real user-managed directory.

The AI-enabled darktable wrapper also creates `${XDG_DATA_HOME:-$HOME/.local/share}/darktable/models` automatically and points it at the bundled model pack. The bundle currently includes denoise, raw denoise, upscale, and object-mask models.

## Install With nix profile

The commands below use `nix profile add`.

Install Spektrafilm:

```sh
nix profile add --extra-experimental-features 'nix-command flakes' github:rafaelcgs10/spektrafilm-art-darktable#spektrafilm
```

Install ART with Spektrafilm:

```sh
nix profile add --extra-experimental-features 'nix-command flakes' github:rafaelcgs10/spektrafilm-art-darktable#spektrafilm-art
```

Install darktable with the native Spektrafilm module:

```sh
nix profile add --extra-experimental-features 'nix-command flakes' github:rafaelcgs10/spektrafilm-art-darktable#darktable-spektrafilm
```

Install darktable with Spektrafilm and darktable AI enabled:

```sh
nix profile add --extra-experimental-features 'nix-command flakes' github:rafaelcgs10/spektrafilm-art-darktable#darktable-spektrafilm-ai
```

After installing, start it with:

```sh
darktable
```

## Home Manager Example

If this flake is an input named `spektrafilm-art`, install darktable like this:

```nix
home.packages = [ spektrafilmPackages.darktable-spektrafilm ];
```

Or use the AI-enabled build:

```nix
home.packages = [ spektrafilmPackages.darktable-spektrafilm-ai ];
```

The package wrapper handles the data-pack symlink on launch. The AI-enabled wrapper also handles the AI models symlink on launch. If you prefer declarative Home Manager links instead, you can still add:

```nix
home.file.".config/darktable/spektrafilm".source =
  spektrafilmPackages.spektrafilm-data-pack;
home.file.".local/share/darktable/models".source =
  spektrafilmPackages.darktable-ai-models;
```

## Darktable Notes

`darktable-spektrafilm` tracks the [darktable Spektrafilm PR](https://github.com/darktable-org/darktable/pull/21534), which adds a native C image operation at `src/iop/spektrafilm.c`.

The data pack is generated reproducibly from this flake's pinned Spektrafilm Python package and a pinned exporter script. It includes `pack.json`, `spectra_lut.f32`, and film/paper profiles. The darktable wrapper links it into `${XDG_CONFIG_HOME:-$HOME/.config}/darktable/spektrafilm` on launch.

The AI model pack is generated from pinned `.dtmodel` assets from `darktable-org/darktable-ai`. The AI-enabled wrapper links it into `${XDG_DATA_HOME:-$HOME/.local/share}/darktable/models` on launch.

## ART Notes

The `ART_agx_film.json` file can be located with:

```sh
find /nix/store/ -type f -name "ART_agx_film.json" | grep -v source
```

This has been tested on Fedora Linux with Nix and on NixOS.
