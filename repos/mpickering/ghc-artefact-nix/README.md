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


## `ghc-head-from` script

The most convenient way to get into the shell is to use the `ghc-head-from` script
which has three modes of operation.

1. Specifying a MR by its number as the first argument fetches artefacts from that MR.
2. Specifying a link to a (fedora27) bindist uses that bindist.
2. Omitting the argument means we fetch the artefact from `ghc/master`.


This is an example of fetching the artefacts for MR 180.

```
> ghc-head-from 180
Fetching from MR: doc: user's guide pragma fixes
Fetching artefact from brprice/wip/doc-pragma-fixes
...
```

or fetching an artefact from HEAD.

```
> ghc-head-from
Fetching artefact from ghc/master
...
```

If you use [`NUR`](https://github.com/nix-community/NUR) then you can access
the script via the attribute `nur.repos.mpickering.ghc-head-from`.

```
nix-shell -p nur.repos.mpickering.ghc-head-from
```

Nesting shells doesn't work very well in Nix so it's probably better to add
the attribute to your `configuration.nix` file and install it globally.



