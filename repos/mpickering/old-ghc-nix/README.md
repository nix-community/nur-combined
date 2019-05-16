This repo contains derivations for all GHC versions.

```
> nix-shell -p nur.repos.mpickering.ghc.ghc801
> ghc --version
The Glorious Glasgow Haskell Compilation System, version 8.0.1
```

It is intended to facilitate the work flow of using nix and cabal new-build together
where nix is used to provide ghc and cabal but not to manage haskell dependencies.

## Using your own bindist

A function is provided so you can use your own bindist if you want.

```
nur.repos.mpickering.ghc.mkGhc { version = "8.9.0"; url = "https://gitlab-artifact-url.com"; hash = "sha256"; }
```

Note that currently none of the artifacts produced by gitlab are suitable to
use with this as the script assumes the bindist has been built for deb8.

## Adding a new release

1. Modify `version.json` with the new release number
2. Run `./update`

