# nur-packages

[NUR](https://github.com/nix-community/NUR) repository of [fclairamb](https://github.com/fclairamb).

![Build and populate cache](https://github.com/fclairamb/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## Packages

| Package | Description |
|---|---|
| `solidping` | [SolidPing](https://github.com/fclairamb/solidping), self-hosted uptime and synthetic monitoring. Prebuilt release binaries for x86_64-linux, aarch64-linux, x86_64-darwin and aarch64-darwin. |

## Usage

Without NUR set up:

```console
$ nix-build https://github.com/fclairamb/nur-packages/archive/main.tar.gz -A solidping
$ ./result/bin/solidping serve
```

With flakes:

```console
$ nix run github:fclairamb/nur-packages#solidping -- serve
```

Once the repository is in NUR:

```console
$ nix-shell -p nur.repos.fclairamb.solidping
```

SolidPing listens on port 4000 and stores its data in SQLite by default. See the [documentation](https://docs.solidping.io).

## License

The Nix expressions in this repository are MIT licensed. SolidPing itself is AGPL-3.0.
