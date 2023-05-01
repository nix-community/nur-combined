{ sources
, stdenv
, lib
, librime
, rimeDataBuildHook
, rime-prelude
, rime-essay
, rime-stroke
}:

stdenv.mkDerivation {
  inherit (sources.rime-terra-pinyin) pname version src;

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
    homepage = "https://github.com/rime/rime-terra-pinyin";
    description = "Terra pinyin for RIME";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
