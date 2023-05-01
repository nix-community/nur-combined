{ sources
, stdenv
, lib
, librime
, rimeDataBuildHook
, rime-prelude
, rime-essay
, rime-luna-pinyin
}:

stdenv.mkDerivation {
  inherit (sources.rime-wugniu) pname version src;

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
    install -Dm644 build/* -t "$out/share/rime-data/build/"
  '';

  passthru.rimeDependencies = [ rime-luna-pinyin ];

  meta = with lib; {
    homepage = "https://github.com/rime/rime-wugniu";
    description = "Wubi pinyin for RIME";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
