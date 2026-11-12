{
  buildEnv,
  makeWrapper,
  zeroad-unwrapped,
  zeroad-data,
  icu77,
  spidermonkey_140,
}:

let
  # 0 A.D. 0.28 targets SpiderMonkey 128, which nixpkgs no longer ships.
  # spidermonkey-140.patch is upstream PR #9350 ("Update SpiderMonkey to ESR
  # 140.1") applied to the 0.28.0 release; only its file renames are adapted to
  # the 0.28.0 tree and the vendored-mozjs/CI hunks are dropped, since we build
  # against system mozjs 140.
  #
  # 0 A.D. takes ICU from pkg-config, so it would pick the default icu (78)
  # while nixpkgs' spidermonkey_140 links icu77 (the ICU Firefox ESR 140
  # ships). Two ICU majors in one binary is unsupported, so build the game
  # against the same ICU as the engine instead of rebuilding mozjs.
  unwrapped = (zeroad-unwrapped.override { icu75 = icu77; }).overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./spidermonkey-140.patch ];

    buildInputs = builtins.filter (x: (x.pname or "") != "spidermonkey") (old.buildInputs or [ ]) ++ [
      spidermonkey_140
    ];
  });
in
assert unwrapped.version == zeroad-data.version;
buildEnv {
  pname = "zeroad_patched";
  inherit (unwrapped) version;

  nativeBuildInputs = [ makeWrapper ];

  paths = [
    unwrapped
    zeroad-data
  ];

  pathsToLink = [
    "/"
    "/bin"
  ];

  postBuild = ''
    for i in $out/bin/*; do
      wrapProgram "$i" \
        --set ZEROAD_ROOTDIR "$out/share/0ad"
    done
  '';

  meta = unwrapped.meta // {
    hydraPlatforms = [ ];
  };
}
