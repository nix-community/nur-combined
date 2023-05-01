{ sources
, stdenv
, lib
, librime
, rimeDataBuildHook
, rime-prelude
, rime-essay
, rime-pinyin-simp
}:

stdenv.mkDerivation {
  inherit (sources.rime-wubi) pname version src;

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

  passthru.rimeDependencies = [ rime-pinyin-simp ];

  meta = with lib; {
    homepage = "https://github.com/rime/rime-wubi";
    description = "Wubi pinyin for RIME";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
