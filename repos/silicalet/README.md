# nur-packages-silicalet

Personal [NUR](https://github.com/nix-community/NUR) packages.

All package sources are pinned by version/tag and hash, so evaluation remains
pure and reproducible.

## Update packages

Update every package that follows a standard upstream tag:

```console
nix run .#update
```

Update selected packages:

```console
nix run .#update -- amber-lsp quien
```

Show the default update set without changing anything:

```console
nix run .#update -- --list
```

The updater is written in [Amber](./maintainers/update.ab) and invokes
`nix-update` with build and formatting enabled. `cangjie` is built from the
upstream source repositories, while the previous vendor binary package remains
available as `cangjie-bin`.
