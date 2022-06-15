lib:

let
  flatten = lib.mapAttrs (_: p: lib.listToAttrs (lib.flatten (lib.mapAttrsToList
    (n1: lib.mapAttrsToList (n2: v: { name = "${n1}.${n2}"; value = v; }))
    p)));
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
    restUrl = "cabal-docspec-$ver/cabal-docspec-$ver.xz";
    src.prefix = "cabal-docspec-";
  };
in
flatten {
  inherit cabal-docspec;
  cabal-docspec-man = cabal-docspec // {
    fetch.url = "https://raw.githubusercontent.com/phadej/cabal-extras/cabal-docspec-$ver/cabal-docspec/cabal-docspec.1";
  };
  hellsmack = github {
    slug = "amesgen/hellsmack";
    restUrl = "v$ver/hellsmack-Linux.zip";
    src.prefix = "v";
  };
  hlint = github {
    slug = "ndmitchell/hlint";
    restUrl = "v$ver/hlint-$ver-x86_64-linux.tar.gz";
    src.prefix = "v";
  };
  ormolu = github {
    slug = "tweag/ormolu";
    restUrl = "$ver/ormolu-Linux.zip";
  };
}
