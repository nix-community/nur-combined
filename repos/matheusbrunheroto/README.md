# NUR packages

Nix package recipes maintained by Matheus Brunheroto.

| Package | Version | Upstream |
| --- | --- | --- |
| gorace | 1.0.0 | [MatheusBrunheroto/gorace](https://github.com/MatheusBrunheroto/gorace) |

## Build or install directly

From this repository's root, with Nixpkgs available in `NIX_PATH`:

```bash
nix-build . -A gorace --arg pkgs 'import <nixpkgs> {}'
./result/bin/gorace --help
```

To install into your user profile:

```bash
nix-env -f . -iA gorace --arg pkgs 'import <nixpkgs> {}'
```

The recipe builds the pinned upstream release from source.

## Use through NUR

NUR registration is pending. Once this repository is included and your NUR
revision contains it, the package will be available as
`pkgs.nur.repos.matheusbrunheroto.gorace`.

With [NUR configured for NixOS](https://github.com/nix-community/NUR#installation):

```nix
environment.systemPackages = [
  pkgs.nur.repos.matheusbrunheroto.gorace
];
```

## License

The Nix recipes and documentation in this repository are MIT licensed.
The software they build keeps its upstream license; gorace is GPL-3.0-or-later.
