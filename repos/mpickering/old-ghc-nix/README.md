This repo contains derivations for all GHC versions.

```
> nix-shell -p nur.repos.mpickering.ghc.ghc801
> ghc --version
The Glorious Glasgow Haskell Compilation System, version 8.0.1
```

It is intended to facilitate the work flow of using nix and cabal new-build together
where nix is used to provide ghc and cabal but not to manage haskell dependencies.

CI pushes the builds to cachix, so that might work, but the nixpkgs version
isn't pinned so don't count on it. The builds don't take very long anyway.

```
cachix use mpickering
```

## Using your own bindist

A function is provided so you can use your own bindist if you want.
The best ones to use from gitlab are the `fedora27` artifacts.

```
nur.repos.mpickering.ghc.mkGhc {  url = "https://gitlab-artifact-url.com"; hash = "sha256"; }
```

The default assumes `ncurses6`, if the platform uses `ncurses5`, for example,
`deb8` then set the `ncursesVersion` attribute as well.

```
nur.repos.mpickering.ghc.mkGhc {  url = "https://gitlab-artifact-url.com"; hash = "sha256"; ncursesVersion = "5"; }
```


## Adding a new release

1. Modify `version.json` with the new release number
2. Run `./update`

