# nur-packages-silicalet

Personal [NUR](https://github.com/nix-community/NUR) packages.

All package sources are pinned by version/tag and hash, so evaluation remains
pure and reproducible.

## Update packages

Update selected packages:

```console
nix run .#update -- amber-lsp quien
```

Update every package that follows a standard upstream tag:

```console
nix run .#update -- --all
```

Running without a package only shows the usage and available package names:

```console
nix run .#update
```

Show the default update set without changing anything:

```console
nix run .#update -- --list
```

The updater is written in [Amber](./maintainers/update.ab) and invokes
`nix-update` with GitHub Releases discovery, build validation, and formatting
enabled. The default update set uses `meatshell-x86_64-bin` and
`nyaterm-x86_64-bin` to avoid rebuilding their slower source packages.
`cangjie` is built from the upstream source repositories, while the previous
vendor binary package remains available as `cangjie-bin`.
