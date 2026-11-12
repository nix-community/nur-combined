{
  buildEnv,
  makeWrapper,
  zeroad-unwrapped,
  zeroad-data,
  spidermonkey_140,
}:

let
  # 0 A.D. 0.28 targets SpiderMonkey 128, which nixpkgs no longer ships.
  # spidermonkey-140.patch ports the source to the ESR 140 API (scope chains,
  # JobQueue::getHostDefinedData, JS::Heap::unsafeAddress) and teaches the
  # premake build to look for mozjs-140 instead of mozjs-128.
  unwrapped = zeroad-unwrapped.overrideAttrs (old: {
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
