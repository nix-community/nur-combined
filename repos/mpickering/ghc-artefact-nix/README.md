This nix expression downloads a recent artefact from `gitlab.haskell.org`
and enters a nix shell with the artefact available. It should work on x86_64-linux,
i386-linux, aarch64-linux and x86_64-darwin.

One simple way to use it is:

```
nix run -f https://github.com/mpickering/ghc-artefact-nix/archive/master.tar.gz ghcHEAD
```

This will enter a shell where the most up to date artefact built for the master
branch is available to use.

You can also specify additional packages to be available from the normal nixpkgs
set. It's often useful to have `cabal` also available.

```
nix run -f https://github.com/mpickering/ghc-artefact-nix/archive/master.tar.gz ghcHEAD cabal-install
```

Finally, you can specify the two options `fork` and `branch` in order to download
an artefact for a contributors branch in order to test a merge request. For
example in order to test [!180](https://gitlab.haskell.org/ghc/ghc/merge_requests/180) which
is on the fork called `brprice` and from branch `wip/doc-pragma-fixes` I can run:

```
nix run -f https://github.com/mpickering/ghc-artefact-nix/archive/master.tar.gz \
      --argstr fork brprice \
      --argstr branch wip/doc-pragma-fixes \
      ghcHEAD cabal-install
```

and then test the compiler locally.




