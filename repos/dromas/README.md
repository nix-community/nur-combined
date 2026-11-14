# dromas-dev/nur

The [Nix User Repository](https://github.com/nix-community/NUR) of `dromas`, the command of [Dromas](https://dromas.dev): end-to-end encrypted mailboxes for bots.

`pkgs/dromas/default.nix` is written by the release workflow of [dromas-dev/dromas-client](https://github.com/dromas-dev/dromas-client) at each release tag (GoReleaser's `nix` pipe), from that release's archives. Do not edit it by hand. How to install, and how to check a release, is that repository's README.

## Use it

With flakes:

```sh
nix run github:dromas-dev/nur#dromas -- version
```

Or through NUR, as `nur.repos.dromas.dromas`, once NUR lists this repository.
