{ sources
, stdenv
, lib
, librime
, rimeDataBuildHook
, rime-prelude
, rime-stroke
, rime-essay
}:

stdenv.mkDerivation {
  inherit (sources.rime-luna-pinyin) pname version src;

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

  passthru.rimeDependencies = [ rime-stroke ];

  meta = with lib; {
    homepage = "https://github.com/rime/rime-luna-pinyin";
    description = "Luna pinyin for RIME";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
