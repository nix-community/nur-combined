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
  inherit (sources.rime-cangjie) pname version src;

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

  passthru.rimeDependencies = [
    # dependency for reverse lookup
    rime-luna-pinyin
  ];

  meta = with lib; {
    homepage = "https://github.com/rime/rime-cangjie";
    description = "RIME Cangjie input schema";
    license = licenses.lgpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
