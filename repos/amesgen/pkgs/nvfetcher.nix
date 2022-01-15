lib:

let
  flatten = lib.mapAttrs (_: p: lib.listToAttrs (lib.flatten (lib.mapAttrsToList
    (n1: lib.mapAttrsToList (n2: v: { name = "${n1}.${n2}"; value = v; }))
    p)));
  github = { slug, useTag, restUrl, src }: {
    fetch.url = "https://github.com/${slug}/releases/download/${restUrl}";
    src = { "github${if useTag then "_tag" else ""}" = slug; } // src;
  };
in
flatten {
  cabal-docspec = github {
    slug = "phadej/cabal-extras";
    useTag = true;
    restUrl = "cabal-docspec-$ver/cabal-docspec-$ver.xz";
    src = { prefix = "cabal-docspec-"; };
  };
  hellsmack = github {
    slug = "amesgen/hellsmack";
    useTag = false;
    restUrl = "v$ver/hellsmack-Linux.zip";
    src = { prefix = "v"; use_latest_release = true; };
  };
  hlint = github {
    slug = "ndmitchell/hlint";
    useTag = false;
    restUrl = "v$ver/hlint-$ver-x86_64-linux.tar.gz";
    src = { prefix = "v"; use_latest_release = true; };
  };
  ormolu = github {
    slug = "tweag/ormolu";
    useTag = false;
    restUrl = "$ver/ormolu-Linux.zip";
    src = { use_latest_release = true; };
  };
}
