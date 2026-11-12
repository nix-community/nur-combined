{
  buildEnv,
  icu,
  makeWrapper,
  zeroad-unwrapped,
  zeroad-data,
  spidermonkey_140,
}:

let
  # nixpkgs' spidermonkey_140 is built against icu77 (the ICU Firefox ESR 140
  # ships), while 0 A.D. and the wxWidgets stack behind its Atlas editor use the
  # default ICU (78). Loading two ICU major versions into one process is not
  # supported: the linker warns about the conflicting libicuuc sonames and only
  # ICU's versioned C++ namespaces keep the two copies apart. icu77 is only a
  # conservative default (mozjs 128 used icu75 for the same reason), so build
  # mozjs against the ICU version the rest of the closure uses.
  spidermonkey = spidermonkey_140.override { icu77 = icu; };

  # 0 A.D. 0.28 targets SpiderMonkey 128, which nixpkgs no longer ships.
  # spidermonkey-140.patch ports the source to the ESR 140 API (scope chains,
  # JobQueue::getHostDefinedData, JS::Heap::unsafeAddress) and teaches the
  # premake build to look for mozjs-140 instead of mozjs-128.
  unwrapped = zeroad-unwrapped.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./spidermonkey-140.patch ];

    buildInputs = builtins.filter (x: (x.pname or "") != "spidermonkey") (old.buildInputs or [ ]) ++ [
      spidermonkey
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
