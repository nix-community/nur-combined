{ lib, stdenv, ... }:

let
  github = { slug, useTag ? false, restUrl, src ? { } }: {
    fetch.url = "https://github.com/${slug}/releases/download/${restUrl}";
    src = lib.recursiveUpdate
      ({ "github${if useTag then "_tag" else ""}" = slug; }
        // lib.optionalAttrs useTag { use_latest_release = true; })
      src;
  };

  cabal-docspec = github {
    slug = "phadej/cabal-extras";
    useTag = true;
    restUrl = "cabal-docspec-$ver/cabal-docspec-$ver-${stdenv.hostPlatform.system}.xz";
    src.prefix = "cabal-docspec-";
  };
in
{
  inherit cabal-docspec;
  cabal-docspec-man = cabal-docspec // {
    fetch.url = "https://raw.githubusercontent.com/phadej/cabal-extras/cabal-docspec-$ver/cabal-docspec/cabal-docspec.1";
  };
  hlint = github {
    slug = "ndmitchell/hlint";
    restUrl = "v$ver/hlint-$ver-x86_64-linux.tar.gz";
    src.prefix = "v";
  };
  ormolu = github {
    slug = "tweag/ormolu";
    restUrl = "$ver/ormolu-x86_64-linux.zip";
  };
  cabal-plan = github {
    slug = "haskell-hvr/cabal-plan";
    restUrl = "v$ver/cabal-plan-$ver-x86_64-linux.xz";
    src.prefix = "v";
  };
  fourmolu = github {
    slug = "fourmolu/fourmolu";
    restUrl = "v$ver/fourmolu-$ver-linux-x86_64";
    src.prefix = "v";
  };
  cabal-gild = github {
    slug = "tfausak/cabal-gild";
    restUrl = "$ver/cabal-gild-$ver-linux-x64.tar.gz";
  };
  hell = github {
    slug = "chrisdone/hell";
    restUrl = "$ver/hell-linux-x86-64bit";
    useTag = true;
    src.include_regex = ''\d{4}-\d{2}-\d{2}'';
  };
}
