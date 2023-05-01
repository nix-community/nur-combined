{ sources
, stdenv
, lib
, librime
, rimeDataBuildHook
, rime-cangjie
, rime-emoji
, rime-loengfan
, rime-luna-pinyin
, rime-stroke
, rime-essay
, rime-prelude
}:

stdenv.mkDerivation {
  inherit (sources.rime-cantonese) pname version src;

  nativeBuildInputs = [
    librime
    rimeDataBuildHook
  ];

  buildInputs = [
    rime-prelude
    rime-essay
  ];

  installPhase = ''
    install -Dm644 *.yaml -t "$out/share/rime-data/"
    install -Dm644 *.txt -t "$out/share/rime-data/"
    install -Dm644 opencc/* -t "$out/share/rime-data/opencc/"
    install -Dm644 build/* -t "$out/share/rime-data/build/"
  '';

  passthru.rimeDependencies = [
    # dependencies for reverse lookup
    rime-cangjie
    rime-loengfan
    rime-luna-pinyin
    rime-stroke

    # opencc config
    rime-emoji
  ];

  meta = with lib; {
    homepage = "https://github.com/rime/rime-cantonese";
    description = "RIME Cantonese input schema";
    license = with licenses; [
      cc-by-40
      odbl
    ];
    maintainers = with maintainers; [ yinfeng ];
  };
}
