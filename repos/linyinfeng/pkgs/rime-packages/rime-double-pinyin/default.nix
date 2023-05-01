{ sources
, stdenv
, lib
, librime
, rimeDataBuildHook
, rime-luna-pinyin
, rime-stroke
, rime-essay
, rime-prelude
}:

stdenv.mkDerivation {
  inherit (sources.rime-double-pinyin) pname version src;

  nativeBuildInputs = [
    librime
    rimeDataBuildHook
  ];

  buildInputs = [
    rime-prelude
    rime-essay
  ];

  propagatedBuildInputs = [
    rime-luna-pinyin
  ];

  installPhase = ''
    install -Dm644 *.yaml -t "$out/share/rime-data/"
    install -Dm644 build/* -t "$out/share/rime-data/build/"
  '';

  passthru.rimeDependencies = [
    # dependency for reverse lookup: rime-stroke
    rime-stroke
  ];

  meta = with lib; {
    homepage = "https://github.com/rime/rime-double-pinyin";
    description = "RIME Double Pinyin input schema";
    license = licenses.gpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
